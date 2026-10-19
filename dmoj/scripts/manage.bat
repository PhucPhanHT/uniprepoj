@echo off
setlocal
cd /d "%~dp0\.."
docker compose exec site python3 manage.py %*
endlocal

