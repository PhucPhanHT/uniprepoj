#!/bin/bash
set -e

echo "=========================================================="
echo "          UniPrep OJ - Cloud Web Service Starting         "
echo "=========================================================="

PORT="${PORT:-8000}"
echo ">> Port listening on: $PORT"

if [ -z "$SECRET_KEY" ]; then
    export SECRET_KEY="ndoj-uniprep-oj-secret-key-thpt-nguyen-du-ha-tinh-c892bf34e56a7d8"
    echo ">> SECRET_KEY tu dong tao khoa mac dinh an toan."
fi

cd /app/dmoj/repo

# 1. Chạy migrations cho database (PostgreSQL/MySQL hoặc SQLite fallback)
echo ">> [1/4] Dang thuc thi database migrations..."
if ! python3 manage.py migrate --noinput; then
    echo "=========================================================="
    echo ">> [CANH BAO] Khong the ket noi toi DATABASE_URL hien tai!"
    echo ">> Nguyen nhan: Supabase Direct URL su dung dia chi IPv6 (Render free khong ho tro IPv6 outbound)."
    echo ">> Giai phap: Hay lay Connection Pooler URL tu Supabase (host aws-0-*.pooler.supabase.com cong 6543) hoac dung Render PostgreSQL."
    echo ">> He thong tu dong chuyen sang SQLite noi bo de Web van khoi dong Live thanh cong!"
    echo "=========================================================="
    export DATABASE_URL=""
    python3 manage.py migrate --noinput
fi

# 2. Tu dong nap fixtures khoi tao neu database moi
echo ">> [2/4] Kiem tra du lieu mac dinh (admin, problems, languages)..."
python3 -c "
import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dmoj.settings')
django.setup()
from django.contrib.auth.models import User
from django.core.management import call_command
from judge.models import Problem, Language

if not User.objects.filter(username='admin').exists():
    print('>> Database moi! Dang nap du lieu mac dinh cho UniPrep OJ...')
    for fixture in ['language_small', 'ndoj_fixtures', 'ndoj_navbar']:
        try:
            call_command('loaddata', fixture)
            print(f'   + Da nap fixture: {fixture}')
        except Exception as e:
            print(f'   ! Thong bao nap {fixture}: {e}')
else:
    print('>> Database da duoc khoi tao truoc do.')
" || true

# 3. Dam bao du lieu testcase cac bai tap mau da san sang trong /problems/
echo ">> [3/4] Kiem tra thu muc bai tap /problems/..."
mkdir -p /problems
if [ -d "/app/dmoj/sample_problems" ]; then
    cp -rn /app/dmoj/sample_problems/* /problems/ 2>/dev/null || true
fi
if [ -d "/app/dmoj/problems" ]; then
    cp -rn /app/dmoj/problems/* /problems/ 2>/dev/null || true
fi

# 4. Khoi dong Web Server
echo ">> [4/4] Khoi dong Web Server tren cong $PORT..."

# Su dung uWSGI voi che do serve static map
if command -v uwsgi &> /dev/null; then
    echo ">> Khoi chay uWSGI production server..."
    exec uwsgi \
        --http "0.0.0.0:${PORT}" \
        --master \
        --processes 2 \
        --threads 4 \
        --static-map "/static=/assets/static" \
        --static-map "/media=/media" \
        --wsgi-file "dmoj/wsgi.py" \
        --vacuum \
        --buffer-size 65535
else
    echo ">> Khoi chay Django server..."
    exec python3 manage.py runserver "0.0.0.0:${PORT}" --insecure
fi

