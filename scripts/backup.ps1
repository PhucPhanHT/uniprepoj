$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$dmojDir = Split-Path -Parent $scriptDir
Set-Location -Path $dmojDir

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "backups"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

$mysqlRootPw = (Get-Content "environment/mysql-admin.env" | Where-Object { $_ -match "^MYSQL_ROOT_PASSWORD=(.*)" } | ForEach-Object { $matches[1] })

Write-Host ">> Dang sao luu Database MySQL sang $backupDir/ndoj_db_$timestamp.sql ..." -ForegroundColor Cyan
docker compose exec -T db mysqldump -u root -p"$mysqlRootPw" ndoj > "$backupDir/ndoj_db_$timestamp.sql"

Write-Host ">> Sao luu hoan tat tai thu muc $backupDir!" -ForegroundColor Green
Get-ChildItem -Path $backupDir

