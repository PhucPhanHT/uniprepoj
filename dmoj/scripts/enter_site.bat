@echo off
setlocal
cd /d "%~dp0\.."
docker compose exec site /bin/bash
endlocal

