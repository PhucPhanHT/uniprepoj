$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$dmojDir = Split-Path -Parent $scriptDir
Set-Location -Path $dmojDir

docker compose exec site /bin/bash

