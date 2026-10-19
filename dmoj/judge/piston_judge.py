import os
import re
import sys
import time
import json
import logging
import threading
import subprocess
import tempfile
try:
    import yaml
except ImportError:
    yaml = None

try:
    import requests
except ImportError:
    requests = None


try:
    from django.conf import settings
    from django.utils import timezone
except ImportError:
    settings = None
    timezone = None


logger = logging.getLogger('judge.piston')

# Mapping from DMOJ language keys to Piston API languages & local commands
LANGUAGE_MAP = {
    # C++
    'CPP03': {'language': 'c++', 'version': '*', 'ext': 'cpp', 'cmd': 'g++'},
    'CPP11': {'language': 'c++', 'version': '*', 'ext': 'cpp', 'cmd': 'g++'},
    'CPP14': {'language': 'c++', 'version': '*', 'ext': 'cpp', 'cmd': 'g++'},
    'CPP17': {'language': 'c++', 'version': '*', 'ext': 'cpp', 'cmd': 'g++'},
    'CPP20': {'language': 'c++', 'version': '*', 'ext': 'cpp', 'cmd': 'g++'},
    'C++':   {'language': 'c++', 'version': '*', 'ext': 'cpp', 'cmd': 'g++'},
    # C
    'C':     {'language': 'c',   'version': '*', 'ext': 'c',   'cmd': 'gcc'},
    'C11':   {'language': 'c',   'version': '*', 'ext': 'c',   'cmd': 'gcc'},
    # Python
    'PY2':   {'language': 'python', 'version': '2.7.18', 'ext': 'py', 'cmd': 'python2'},
    'PY3':   {'language': 'python', 'version': '3.10.0', 'ext': 'py', 'cmd': 'python3'},
    'PYTHON':{'language': 'python', 'version': '3.10.0', 'ext': 'py', 'cmd': 'python3'},
    'PYTHON3':{'language': 'python','version': '3.10.0', 'ext': 'py', 'cmd': 'python3'},
    # Pascal
    'PAS':   {'language': 'pascal', 'version': '*', 'ext': 'pas', 'cmd': 'fpc'},
    # Java
    'JAVA':  {'language': 'java', 'version': '*', 'ext': 'java', 'cmd': 'javac'},
    'JAVA8': {'language': 'java', 'version': '*', 'ext': 'java', 'cmd': 'javac'},
    'JAVA11':{'language': 'java', 'version': '*', 'ext': 'java', 'cmd': 'javac'},
    # JavaScript
    'JS':    {'language': 'javascript', 'version': '*', 'ext': 'js', 'cmd': 'node'},
    'NODE':  {'language': 'javascript', 'version': '*', 'ext': 'js', 'cmd': 'node'},
}


def natural_sort_key(s):
    """Sort strings containing numbers in human order (1, 2, 10 instead of 1, 10, 2)."""
    return [int(text) if text.isdigit() else text.lower() for text in re.split(r'(\d+)', str(s))]


def find_test_cases(problem_code):
    """Locate and load testcases for a problem from storage."""
    candidate_roots = [
        getattr(settings, 'DMOJ_PROBLEM_DATA_ROOT', '/problems/'),
        '/problems',
        os.path.join(settings.BASE_DIR, 'problems'),
        os.path.join(settings.BASE_DIR, 'sample_problems'),
        os.path.join(os.path.dirname(settings.BASE_DIR), 'problems'),
        os.path.join(os.path.dirname(settings.BASE_DIR), 'sample_problems'),
        os.path.join(os.path.dirname(settings.BASE_DIR), 'dmoj', 'problems'),
        os.path.join(os.path.dirname(settings.BASE_DIR), 'dmoj', 'sample_problems'),
    ]

    problem_dir = None
    for root in candidate_roots:
        if not root:
            continue
        p = os.path.join(root, problem_code)
        if os.path.isdir(p):
            problem_dir = p
            break

    if not problem_dir:
        logger.warning("Could not find problem directory for code: %s in %s", problem_code, candidate_roots)
        return []

    test_cases = []

    # 1. Try init.yml first
    init_path = os.path.join(problem_dir, 'init.yml')
    if os.path.isfile(init_path):
        try:
            with open(init_path, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
            if data and 'test_cases' in data and isinstance(data['test_cases'], list):
                for item in data['test_cases']:
                    in_file = os.path.join(problem_dir, item.get('in', ''))
                    out_file = os.path.join(problem_dir, item.get('out', ''))
                    in_data = ''
                    out_data = ''
                    if os.path.isfile(in_file):
                        with open(in_file, 'r', encoding='utf-8', errors='replace') as inf:
                            in_data = inf.read()
                    if os.path.isfile(out_file):
                        with open(out_file, 'r', encoding='utf-8', errors='replace') as outf:
                            out_data = outf.read()

                    test_cases.append({
                        'input': in_data,
                        'output': out_data,
                        'points': float(item.get('points', 1.0)),
                    })
                if test_cases:
                    return test_cases
        except Exception as e:
            logger.warning("Error reading init.yml in %s: %s", problem_dir, e)

    # 2. Fallback: discover *.in and *.out files
    in_files = [f for f in os.listdir(problem_dir) if f.endswith('.in')]
    in_files.sort(key=natural_sort_key)

    for inf in in_files:
        base = inf[:-3]
        out_name = f"{base}.out"
        in_path = os.path.join(problem_dir, inf)
        out_path = os.path.join(problem_dir, out_name)

        in_data = ''
        out_data = ''
        if os.path.isfile(in_path):
            with open(in_path, 'r', encoding='utf-8', errors='replace') as f:
                in_data = f.read()
        if os.path.isfile(out_path):
            with open(out_path, 'r', encoding='utf-8', errors='replace') as f:
                out_data = f.read()

        test_cases.append({
            'input': in_data,
            'output': out_data,
            'points': 1.0,
        })

    return test_cases


def check_output(actual: str, expected: str) -> bool:
    """Compare student output with expected output using standard whitespace trimming."""
    if actual is None:
        actual = ''
    if expected is None:
        expected = ''

    actual_lines = [line.rstrip() for line in actual.replace('\r\n', '\n').split('\n')]
    expected_lines = [line.rstrip() for line in expected.replace('\r\n', '\n').split('\n')]

    while actual_lines and actual_lines[-1] == '':
        actual_lines.pop()
    while expected_lines and expected_lines[-1] == '':
        expected_lines.pop()

    return actual_lines == expected_lines


def execute_locally(lang_info, source_code, stdin_data, time_limit_sec):
    """Execute code locally using system compilers/interpreters as a zero-dependency fallback."""
    lang = lang_info['language']

    if lang == 'python':
        try:
            res = subprocess.run(
                [sys.executable, '-c', source_code],
                input=stdin_data,
                capture_output=True,
                text=True,
                timeout=time_limit_sec
            )
            if res.returncode != 0:
                return {'status': 'RTE', 'stdout': res.stdout, 'stderr': res.stderr}
            return {'status': 'OK', 'stdout': res.stdout, 'stderr': res.stderr}
        except subprocess.TimeoutExpired:
            return {'status': 'TLE', 'stdout': '', 'stderr': 'Time Limit Exceeded'}
        except Exception as e:
            return {'status': 'RTE', 'stdout': '', 'stderr': str(e)}

    elif lang in ('c', 'c++'):
        compiler = 'g++' if lang == 'c++' else 'gcc'
        std_flag = '-std=c++17' if lang == 'c++' else '-std=c11'
        with tempfile.TemporaryDirectory() as tmpdir:
            src_file = os.path.join(tmpdir, f"solution.{lang_info['ext']}")
            bin_file = os.path.join(tmpdir, "solution.exe" if sys.platform == 'win32' else "solution")
            with open(src_file, 'w', encoding='utf-8') as f:
                f.write(source_code)

            try:
                c_res = subprocess.run(
                    [compiler, '-O2', std_flag, src_file, '-o', bin_file, '-lm'],
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                if c_res.returncode != 0:
                    return {'status': 'CE', 'log': c_res.stderr}
            except FileNotFoundError:
                return {'status': 'CE', 'log': f'Trình biên dịch {compiler} chưa được cài đặt trên máy chủ.'}
            except subprocess.TimeoutExpired:
                return {'status': 'CE', 'log': 'Thời gian biên dịch vượt quá giới hạn (Compile Timeout).'}

            try:
                run_res = subprocess.run(
                    [bin_file],
                    input=stdin_data,
                    capture_output=True,
                    text=True,
                    timeout=time_limit_sec
                )
                if run_res.returncode != 0:
                    return {'status': 'RTE', 'stdout': run_res.stdout, 'stderr': run_res.stderr}
                return {'status': 'OK', 'stdout': run_res.stdout, 'stderr': run_res.stderr}
            except subprocess.TimeoutExpired:
                return {'status': 'TLE', 'stdout': '', 'stderr': 'Time Limit Exceeded'}
            except Exception as e:
                return {'status': 'RTE', 'stdout': '', 'stderr': str(e)}

    return {'status': 'IE', 'stdout': '', 'stderr': f'Ngôn ngữ {lang} chưa được hỗ trợ trên trình chấm nội bộ.'}


def execute_code(lang_info, source_code, stdin_data, time_limit_sec, memory_limit_kb):
    """Execute code via Piston API endpoint or fallback to local execution."""
    piston_url = getattr(settings, 'PISTON_API_URL', os.environ.get('PISTON_API_URL', 'http://piston:2000/api/v2/execute'))
    piston_key = getattr(settings, 'PISTON_API_KEY', os.environ.get('PISTON_API_KEY', ''))
    fallback_local = getattr(settings, 'PISTON_FALLBACK_LOCAL', True)

    # 1. Try Piston API if configured
    if piston_url:
        try:
            headers = {'Content-Type': 'application/json'}
            if piston_key:
                headers['Authorization'] = piston_key if 'Bearer' in piston_key else f'Bearer {piston_key}'

            payload = {
                'language': lang_info['language'],
                'version': lang_info.get('version', '*'),
                'files': [{'name': f"solution.{lang_info['ext']}", 'content': source_code}],
                'stdin': stdin_data,
                'run_timeout': int(time_limit_sec * 1000),
                'compile_timeout': 10000,
            }

            resp = requests.post(piston_url, json=payload, headers=headers, timeout=time_limit_sec + 6)
            if resp.status_code == 200:
                data = resp.json()
                compile_data = data.get('compile')
                if compile_data and compile_data.get('code', 0) != 0:
                    return {'status': 'CE', 'log': compile_data.get('output', 'Compile Error')}

                run_data = data.get('run', {})
                code = run_data.get('code')
                signal = run_data.get('signal')
                stdout = run_data.get('stdout', '')
                stderr = run_data.get('stderr', '')

                if signal in ('SIGKILL', 'SIGXCPU') or code == 137 or 'timed out' in stderr.lower():
                    return {'status': 'TLE', 'stdout': stdout, 'stderr': stderr}
                if code != 0 and code is not None:
                    return {'status': 'RTE', 'stdout': stdout, 'stderr': stderr}

                return {'status': 'OK', 'stdout': stdout, 'stderr': stderr}
            else:
                logger.warning("Piston API HTTP %s: %s", resp.status_code, resp.text)
        except Exception as e:
            logger.warning("Piston API call error (%s), attempting local runner fallback...", e)

    # 2. Local Fallback Sandbox Execution
    if fallback_local:
        return execute_locally(lang_info, source_code, stdin_data, time_limit_sec)

    return {'status': 'IE', 'stdout': '', 'stderr': 'Execution engine unavailable'}


def judge_submission_piston(submission_id):
    """Core judging logic for a single submission using Piston API."""
    from judge.models import Submission, SubmissionTestCase
    from judge.caching import finished_submission
    from judge import event_poster as event
    from judge.judgeapi import _post_update_submission

    try:
        submission = Submission.objects.select_related('problem', 'language', 'user').get(id=submission_id)
    except Submission.DoesNotExist:
        logger.error("Submission %s does not exist", submission_id)
        return False

    problem = submission.problem
    language = submission.language
    source_code = submission.source.source

    # Update to Processing state
    Submission.objects.filter(id=submission_id).update(status='P', current_testcase=0)
    event.post(f'sub_{submission.id_secret}', {'type': 'grading-begin'})
    _post_update_submission(submission)

    test_cases = find_test_cases(problem.code)
    if not test_cases:
        logger.warning("No test cases found for problem %s", problem.code)
        Submission.objects.filter(id=submission_id).update(
            status='IE',
            result='IE',
            error=f'Không tìm thấy bộ dữ liệu testcase cho bài "{problem.code}". Vui lòng thêm thư mục vào problems/{problem.code}.'
        )
        _post_update_submission(submission, done=True)
        return False

    lang_info = LANGUAGE_MAP.get(language.key.upper(), {
        'language': language.key.lower(),
        'version': '*',
        'ext': language.extension or 'txt',
        'cmd': 'python3'
    })

    time_limit_sec = float(problem.time_limit or 1.0)
    memory_limit_kb = int(problem.memory_limit or 65536)

    total_possible_points = sum(tc['points'] for tc in test_cases)
    total_earned_points = 0.0
    total_time = 0.0
    max_memory = 0
    final_result = 'AC'
    compile_error_log = None

    severity_order = {'CE': 6, 'IE': 5, 'RTE': 4, 'TLE': 3, 'WA': 2, 'AC': 1}

    # Clean existing test cases for this submission
    SubmissionTestCase.objects.filter(submission_id=submission_id).delete()

    for idx, tc in enumerate(test_cases, start=1):
        case_points = tc['points']
        stdin_content = tc['input']
        expected_out = tc['output']

        start_t = time.monotonic()
        exec_result = execute_code(
            lang_info=lang_info,
            source_code=source_code,
            stdin_data=stdin_content,
            time_limit_sec=time_limit_sec,
            memory_limit_kb=memory_limit_kb
        )
        elapsed_t = round(time.monotonic() - start_t, 3)
        total_time += elapsed_t

        case_status = exec_result['status']
        actual_output = exec_result.get('stdout', '')

        if case_status == 'CE':
            compile_error_log = exec_result.get('log', 'Compile Error')
            final_result = 'CE'
            break

        if case_status == 'OK':
            if check_output(actual_output, expected_out):
                case_status = 'AC'
                earned = case_points
            else:
                case_status = 'WA'
                earned = 0.0
        else:
            earned = 0.0

        if severity_order.get(case_status, 0) > severity_order.get(final_result, 0):
            final_result = case_status

        total_earned_points += earned

        # Record test case in DB
        SubmissionTestCase.objects.create(
            submission=submission,
            case=idx,
            status=case_status,
            time=elapsed_t,
            memory=exec_result.get('memory', 0),
            points=earned,
            total=case_points,
            feedback='Accepted' if case_status == 'AC' else case_status,
            output=actual_output[:1024] if case_status != 'AC' else '',
        )

        Submission.objects.filter(id=submission_id).update(current_testcase=idx)
        event.post(f'sub_{submission.id_secret}', {
            'type': 'test-case',
            'id': idx,
        })
        _post_update_submission(submission)

    # Save final submission state
    submission.refresh_from_db()

    if final_result == 'CE':
        submission.status = 'CE'
        submission.result = 'CE'
        submission.error = compile_error_log
        submission.points = 0.0
        submission.case_points = 0.0
        submission.case_total = total_possible_points
        submission.time = 0.0
        submission.memory = 0
        submission.save()

        event.post(f'sub_{submission.id_secret}', {
            'type': 'compile-error',
            'log': compile_error_log,
        })
        _post_update_submission(submission, done=True)
        return True

    submission.status = 'D'
    submission.result = final_result
    submission.case_points = round(total_earned_points, 1)
    submission.case_total = round(total_possible_points, 1)

    problem_points = float(problem.points or 10.0)
    if total_possible_points > 0:
        calculated_points = round((total_earned_points / total_possible_points) * problem_points, 2)
    else:
        calculated_points = 0.0

    if not problem.partial and calculated_points != problem_points:
        calculated_points = 0.0

    submission.points = calculated_points
    submission.time = round(total_time, 3)
    submission.memory = max_memory
    submission.save()

    # Update stats, contest and points
    try:
        if problem.is_public and not problem.is_organization_private:
            submission.user._updating_stats_only = True
            submission.user.calculate_points()

        problem._updating_stats_only = True
        problem.update_stats()
        submission.update_contest()
        finished_submission(submission)
    except Exception as e:
        logger.warning("Error updating stats/points after judging: %s", e)

    # Post final grading-end event
    event.post(f'sub_{submission.id_secret}', {
        'type': 'grading-end',
        'time': submission.time,
        'memory': submission.memory,
        'points': float(submission.points),
        'total': float(problem.points),
        'result': submission.result,
    })
    _post_update_submission(submission, done=True)
    return True


def _run_judge_thread(submission_id):
    from django import db
    try:
        db.connection.close_if_unusable_or_obsolete()
        judge_submission_piston(submission_id)
    except Exception as e:
        logger.exception("Error in Piston judge thread for submission %s: %s", submission_id, e)
    finally:
        db.connection.close()


def start_piston_judge(submission_id):
    """Spawns an asynchronous background thread to judge submission via Piston."""
    t = threading.Thread(target=_run_judge_thread, args=(submission_id,), daemon=True)
    t.start()
    return t
