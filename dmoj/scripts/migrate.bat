@echo off
setlocal
cd /d "%~dp0\.."
echo ^>^> Dang chay migration database NDOJ...
docker compose exec site python3 manage.py migrate
endlocal

