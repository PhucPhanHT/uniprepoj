@echo off
setlocal
cd /d "%~dp0\.."

echo ^>^> Dang kiem tra thu muc: %CD%

if not exist "repo\resources\libs\latinmodernmath\latinmodern-math.eot" (
    echo ^>^> Dang tai cac git submodules...
    git submodule update --init --recursive
    if exist "repo" (
        pushd repo
        git submodule update --init --recursive
        popd
    )
)

echo ^>^> Dang tao cac thu muc luu tru...
if not exist "problems" mkdir problems
if not exist "media" mkdir media
if not exist "database" mkdir database
if not exist "backups" mkdir backups

echo ^>^> Dang sao chep cac file cau hinh...
copy /Y config\config.js repo\websocket\config.js >nul
copy /Y config\local_settings.py repo\dmoj\local_settings.py >nul
if exist "config\local_urls.py" copy /Y config\local_urls.py repo\dmoj\local_urls.py >nul
copy /Y config\uwsgi.ini repo\uwsgi.ini >nul
copy /Y config\judge.yml problems\judge.yml >nul
if exist "judge\piston_judge.py" copy /Y judge\piston_judge.py repo\judge\piston_judge.py >nul
if exist "judge\judgeapi.py" copy /Y judge\judgeapi.py repo\judge\judgeapi.py >nul
if exist "manage.py" copy /Y manage.py repo\manage.py >nul
if exist "wsgi.py" copy /Y wsgi.py repo\dmoj\wsgi.py >nul
if exist "additional_requirements.txt" copy /Y additional_requirements.txt repo\additional_requirements.txt >nul

if not exist "repo\judge\fixtures" mkdir "repo\judge\fixtures"
if not exist "repo\resources\icons" mkdir "repo\resources\icons"

xcopy /E /I /Y fixtures repo\judge\fixtures >nul 2>&1
xcopy /E /I /Y resources repo\resources >nul 2>&1
xcopy /E /I /Y sample_problems problems >nul 2>&1

echo ^>^> Khoi tao thu muc va cau hinh NDOJ hoan tat!
endlocal

