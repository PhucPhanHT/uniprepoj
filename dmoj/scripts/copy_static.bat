@echo off
setlocal
cd /d "%~dp0\.."
echo ^>^> Dang bien dich va thu thap static assets NDOJ...
docker compose exec site /bin/bash -c "bash make_style.sh && python3 manage.py collectstatic --noinput && python3 manage.py compilemessages && python3 manage.py compilejsi18n && cp -r resources/ /assets/ && rm resources/style.css resources/martor-description.css resources/select2-dmoj.css && rm resources/dark/style.css resources/dark/martor-description.css resources/dark/select2-dmoj.css && rm -r sass_processed && cp 502.html /assets/ && cp logo.png /assets/ && cp -f resources/icons/logo.svg /assets/logo.svg 2>/dev/null || true && cp robots.txt /assets/"
echo ^>^> Thu thap static assets hoan tat!
endlocal

