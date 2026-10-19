# PowerShell helper: Nạp dữ liệu khởi tạo NDOJ
Write-Host ">> Đang nạp fixtures navbar, language và dữ liệu khởi tạo NDOJ..." -ForegroundColor Cyan
docker compose exec site python3 manage.py loaddata ndoj_navbar
docker compose exec site python3 manage.py loaddata language_small
docker compose exec site python3 manage.py loaddata ndoj_fixtures

Write-Host ">> Đang cấu hình máy chấm ndoj_judge_1..." -ForegroundColor Cyan
docker compose exec site python3 manage.py shell -c "from judge.models import Judge; j, created = Judge.objects.get_or_create(name='ndoj_judge_1', defaults={'auth_key': 'ndoj_secret_judge_key_2026', 'is_blocked': False, 'description': 'Máy chấm tự động Docker NDOJ 01'}); print('Máy chấm ndoj_judge_1 đã được cấu hình thành công!')"

Write-Host ">> Khởi tạo dữ liệu NDOJ hoàn tất!" -ForegroundColor Green
