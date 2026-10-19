param(
    [string]$backupFile
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$dmojDir = Split-Path -Parent $scriptDir
Set-Location -Path $dmojDir

$backupDir = "backups"

if (-not $backupFile) {
    $latest = Get-ChildItem -Path $backupDir -Filter "*.sql" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) {
        Write-Host "[LOI] Khong tim thay file backup nao trong thu muc $backupDir!" -ForegroundColor Red
        exit 1
    }
    $backupFileName = $latest.Name
} else {
    $backupFileName = Split-Path -Leaf $backupFile
    if (-not (Test-Path "$backupDir\$backupFileName")) {
        Write-Host "[LOI] File $backupDir\$backupFileName khong ton tai!" -ForegroundColor Red
        exit 1
    }
}

$mysqlRootPw = (Get-Content "environment/mysql-admin.env" | Where-Object { $_ -match "^MYSQL_ROOT_PASSWORD=(.*)" } | ForEach-Object { $matches[1] })

Write-Host ">> Dang khoi phuc Database tu file: $backupDir/$backupFileName ..." -ForegroundColor Cyan
docker compose exec db sh -c "mariadb -u root -p'$mysqlRootPw' --default-character-set=utf8mb4 ndoj < /backups/$backupFileName"

Write-Host ">> Khoi phuc Database hoan tat thanh cong!" -ForegroundColor Green
