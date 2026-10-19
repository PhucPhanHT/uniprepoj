@echo off
setlocal
cd /d "%~dp0\.."
echo ^>^> Dang nap fixtures navbar, language va du lieu khoi tao NDOJ...
docker compose exec site python3 manage.py loaddata ndoj_navbar
docker compose exec site python3 manage.py loaddata language_small
docker compose exec site python3 manage.py loaddata ndoj_fixtures

echo ^>^> Dang cau hinh may cham ndoj_judge_1...
docker compose exec site python3 manage.py shell -c "import os; from judge.models import Judge; name = os.environ.get('JUDGE_NAME', 'ndoj_judge_1'); key = os.environ.get('JUDGE_KEY', 'ndoj_secret_judge_key_2026'); j, created = Judge.objects.get_or_create(name=name, defaults={'auth_key': key, 'is_blocked': False, 'description': 'May cham tu dong Docker NDOJ 01'}); (not created and setattr(j, 'auth_key', key) or True) and setattr(j, 'is_blocked', False) and j.save(); print(f'May cham {name} da duoc cau hinh thanh cong!')"

echo ^>^> Dang khoi dong lai cac dich vu bridged va judge...
docker compose restart bridged site judge >nul 2>&1

echo ^>^> Khoi tao du lieu NDOJ hoan tat!
endlocal

