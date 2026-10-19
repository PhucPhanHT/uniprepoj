# PowerShell helper: Tạo hoặc cập nhật tài khoản Super Admin
param(
    [string]$Username = "admin",
    [string]$Password = "NguyenDu@2026",
    [string]$Email = "admin@ndoj.edu.vn"
)

Write-Host ">> Đang tạo hoặc cập nhật tài khoản Superuser: $Username ..." -ForegroundColor Cyan
docker compose exec site python3 manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); u, c = User.objects.get_or_create(username='$Username', defaults={'email': '$Email', 'is_superuser': True, 'is_staff': True}); u.set_password('$Password'); u.save(); print('Tài khoản Superuser $Username đã sẵn sàng!')"
