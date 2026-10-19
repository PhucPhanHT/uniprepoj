@echo off
setlocal
cd /d "%~dp0\.."

set USERNAME=%1
if "%USERNAME%"=="" set USERNAME=admin

set PASSWORD=%2
if "%PASSWORD%"=="" set PASSWORD=NguyenDu@2026

set EMAIL=%3
if "%EMAIL%"=="" set EMAIL=admin@uniprepoj.com

echo ^>^> Dang tao hoac cap nhat tai khoan Superuser: %USERNAME% ...
docker compose exec site python3 manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); u = User.objects.filter(username='%USERNAME%').first(); (u.set_password('%PASSWORD%') or setattr(u, 'email', '%EMAIL%') or setattr(u, 'is_superuser', True) or setattr(u, 'is_staff', True) or u.save() or print('Da cap nhat mat khau cho tai khoan %USERNAME% thanh cong!')) if u else (User.objects.create_superuser('%USERNAME%', '%EMAIL%', '%PASSWORD%') and print('Da tao thanh cong tai khoan Superuser: %USERNAME%!'))"

endlocal

