# PowerShell script khởi tạo cấu hình NDOJ
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$dmojDir = Join-Path $projectDir "dmoj"

Write-Host ">> Đang khởi tạo thư mục và cấu hình NDOJ..." -ForegroundColor Cyan

# Tạo các thư mục cần thiết trong dmoj
New-Item -ItemType Directory -Force -Path (Join-Path $dmojDir "problems") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $dmojDir "media") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $dmojDir "database") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $dmojDir "backups") | Out-Null

# Copy configs vào submodule repo
Copy-Item -Force (Join-Path $dmojDir "config\config.js") (Join-Path $dmojDir "repo\websocket\config.js")
Copy-Item -Force (Join-Path $dmojDir "config\local_settings.py") (Join-Path $dmojDir "repo\dmoj\local_settings.py")
Copy-Item -Force (Join-Path $dmojDir "config\uwsgi.ini") (Join-Path $dmojDir "repo\uwsgi.ini")
Copy-Item -Force (Join-Path $dmojDir "config\judge.yml") (Join-Path $dmojDir "problems\judge.yml")

# Copy fixtures và branding NDOJ
New-Item -ItemType Directory -Force -Path (Join-Path $dmojDir "repo\judge\fixtures") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $dmojDir "repo\resources\icons") | Out-Null

if (Test-Path (Join-Path $dmojDir "fixtures")) {
    Copy-Item -Force -Recurse (Join-Path $dmojDir "fixtures\*") (Join-Path $dmojDir "repo\judge\fixtures\")
}
if (Test-Path (Join-Path $dmojDir "resources")) {
    Copy-Item -Force -Recurse (Join-Path $dmojDir "resources\*") (Join-Path $dmojDir "repo\resources\")
}

# Copy sample problems
if (Test-Path (Join-Path $dmojDir "sample_problems")) {
    Copy-Item -Force -Recurse (Join-Path $dmojDir "sample_problems\*") (Join-Path $dmojDir "problems\")
}

Write-Host ">> Khởi tạo thư mục và cấu hình NDOJ thành công!" -ForegroundColor Green
