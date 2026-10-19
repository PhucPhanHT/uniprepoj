#!/bin/bash
# ==============================================================================
# KỊCH BẢN CÀI ĐẶT 1-CHẠM HỆ THỐNG NDOJ TRÊN MÁY CHỦ LINUX (UBUNTU/DEBIAN)
# Trường THPT Nguyễn Du - Huyện Nghi Xuân, Tỉnh Hà Tĩnh
# ==============================================================================

set -e

# Màu sắc hiển thị
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================================${NC}"
echo -e "${GREEN}      HỆ THỐNG CHẤM BÀI TỰ ĐỘNG NDOJ - THPT NGUYỄN DU HÀ TĨNH     ${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo -e "${YELLOW}>> Đang khởi chạy trình cài đặt tự động...${NC}"

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[LỖI] Vui lòng chạy kịch bản này với quyền root: sudo bash $0${NC}"
  exit 1
fi

PROJECT_DIR="$(cd "$(dirname "$(dirname "$0")")" && pwd)"
DMOJ_DIR="$PROJECT_DIR/dmoj"

echo -e "${BLUE}>> Thư mục dự án: $PROJECT_DIR${NC}"

# 1. Cài đặt các gói phụ trợ cần thiết
echo -e "${GREEN}[1/7] Cập nhật hệ điều hành và cài đặt các gói cần thiết...${NC}"
apt-get update -qq
apt-get install -y -qq curl wget git ufw gzip tar openssl

# 2. Cài đặt Docker & Docker Compose nếu chưa có
echo -e "${GREEN}[2/7] Kiểm tra Docker & Docker Compose...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}>> Chưa tìm thấy Docker. Đang tiến hành cài đặt Docker Engine chính thức...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}>> Cài đặt Docker thành công!${NC}"
else
    echo -e "${GREEN}>> Docker đã được cài đặt: $(docker --version)${NC}"
fi

# 3. Mở cổng tường lửa UFW
echo -e "${GREEN}[3/7] Cấu hình tường lửa UFW (Port 22 SSH, Port 80 HTTP, Port 443 HTTPS)...${NC}"
ufw allow 22/tcp > /dev/null 2>&1 || true
ufw allow 80/tcp > /dev/null 2>&1 || true
ufw allow 443/tcp > /dev/null 2>&1 || true
ufw allow 9999/tcp > /dev/null 2>&1 || true

# 4. Tự động sinh mã bảo mật cho môi trường (Environment Secrets)
echo -e "${GREEN}[4/7] Thiết lập biến môi trường và mật khẩu bảo mật...${NC}"
cd "$DMOJ_DIR"

if [ ! -f "environment/mysql.env" ]; then
    cp environment/mysql.env.example environment/mysql.env 2>/dev/null || true
fi
if [ ! -f "environment/mysql-admin.env" ]; then
    cp environment/mysql-admin.env.example environment/mysql-admin.env 2>/dev/null || true
fi
if [ ! -f "environment/site.env" ]; then
    cp environment/site.env.example environment/site.env 2>/dev/null || true
fi

# Tạo mật khẩu ngẫu nhiên an toàn nếu đang dùng giá trị mặc định
GEN_DB_PASS=$(openssl rand -hex 12)
GEN_ROOT_PASS=$(openssl rand -hex 16)
GEN_SECRET=$(openssl rand -hex 24)
GEN_JUDGE_KEY=$(openssl rand -hex 16)

# Cập nhật vào các file .env
sed -i "s/ndoj_db_password_2026/$GEN_DB_PASS/g" environment/mysql.env 2>/dev/null || true
sed -i "s/ndoj_root_password_2026/$GEN_ROOT_PASS/g" environment/mysql-admin.env 2>/dev/null || true
sed -i "s/ndoj_secret_judge_key_2026/$GEN_JUDGE_KEY/g" environment/site.env 2>/dev/null || true
sed -i "s/ndoj-secret-key-thpt-nguyen-du-ha-tinh-c892bf34e56a7d8/$GEN_SECRET/g" environment/site.env 2>/dev/null || true
sed -i "s/ndoj_secret_judge_key_2026/$GEN_JUDGE_KEY/g" config/judge.yml 2>/dev/null || true
sed -i "s/ndoj_secret_judge_key_2026/$GEN_JUDGE_KEY/g" docker-compose.yml 2>/dev/null || true
sed -i "s/ndoj_secret_judge_key_2026/$GEN_JUDGE_KEY/g" repo/judge/fixtures/ndoj_fixtures.json 2>/dev/null || true

# Cấp quyền thực thi cho các kịch bản
chmod +x scripts/*

# 5. Khởi tạo cấu hình và thư mục
echo -e "${GREEN}[5/7] Khởi tạo cấu hình submodule và thư mục lưu trữ bài tập...${NC}"
./scripts/initialize

# 6. Build Docker images và khởi chạy containers
echo -e "${GREEN}[6/7] Đang xây dựng và khởi động các dịch vụ NDOJ (Site, Database, Redis, Celery, Nginx, Judge)...${NC}"
docker compose build
docker compose up -d

echo -e "${YELLOW}>> Đang chờ cơ sở dữ liệu MariaDB sẵn sàng (15 giây)...${NC}"
sleep 15

# Chạy migration database
echo -e "${GREEN}>> Đang khởi tạo bảng cơ sở dữ liệu (Migration)...${NC}"
./scripts/migrate

# Biên dịch và thu thập static assets
echo -e "${GREEN}>> Đang biên dịch giao diện và thu thập Static Assets...${NC}"
./scripts/copy_static

# Nạp dữ liệu khởi tạo NDOJ
echo -e "${GREEN}>> Đang nạp bộ bài tập mẫu và dữ liệu ban đầu cho THPT Nguyễn Du...${NC}"
./scripts/seed_ndoj

# Tạo tài khoản Admin mặc định
echo -e "${GREEN}>> Đang khởi tạo tài khoản Quản trị viên (Super Admin)...${NC}"
./scripts/create_admin admin "NguyenDu@2026" "admin@ndoj.edu.vn"

# Lấy địa chỉ IP máy chủ
SERVER_IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')

echo -e "\n${BLUE}==================================================================${NC}"
echo -e "${GREEN}🎉 CHÚC MỪNG! HỆ THỐNG NDOJ ĐÃ ĐƯỢC CÀI ĐẶT THÀNH CÔNG RỰC RỠ! 🎉${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo -e "Trường: ${YELLOW}Trường THPT Nguyễn Du - Hà Tĩnh${NC}"
echo -e "Địa chỉ truy cập Web: ${GREEN}http://$SERVER_IP/${NC} (hoặc http://localhost/ nếu chạy trên máy nội bộ)"
echo -e "Tài khoản Quản trị (Super Admin):"
echo -e "   - Tên đăng nhập: ${YELLOW}admin${NC}"
echo -e "   - Mật khẩu:       ${YELLOW}NguyenDu@2026${NC}"
echo -e "   - Email:          ${YELLOW}admin@ndoj.edu.vn${NC}"
echo -e "\n${YELLOW}>> Lưu ý:${NC} Sau khi đăng nhập lần đầu, quý thầy cô vui lòng đổi lại mật khẩu tại trang Quản trị."
echo -e "Để cấu hình tên miền và SSL HTTPS Let's Encrypt miễn phí, hãy chạy: ${GREEN}sudo bash $PROJECT_DIR/scripts/setup_ssl.sh your-domain.edu.vn${NC}"
echo -e "${BLUE}==================================================================${NC}\n"
