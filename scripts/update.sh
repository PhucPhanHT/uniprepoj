#!/bin/bash
# ==============================================================================
# KỊCH BẢN CẬP NHẬT HỆ THỐNG NDOJ (KHÔNG MẤT DỮ LIỆU)
# Trường THPT Nguyễn Du - Huyện Nghi Xuân, Tỉnh Hà Tĩnh
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "$(dirname "$0")")" && pwd)"
DMOJ_DIR="$PROJECT_DIR/dmoj"

echo -e "${BLUE}>> Đang tiến hành sao lưu dữ liệu trước khi cập nhật...${NC}"
cd "$DMOJ_DIR"
./scripts/backup

echo -e "${GREEN}>> Đang build lại Docker containers nếu có thay đổi...${NC}"
docker compose build

echo -e "${GREEN}>> Đang khởi động lại dịch vụ...${NC}"
docker compose up -d

echo -e "${GREEN}>> Đang chạy migration cơ sở dữ liệu...${NC}"
./scripts/migrate

echo -e "${GREEN}>> Đang cập nhật static assets...${NC}"
./scripts/copy_static

echo -e "${BLUE}==================================================================${NC}"
echo -e "${GREEN}🎉 Hệ thống NDOJ đã được cập nhật thành công và đang hoạt động ổn định!${NC}"
echo -e "${BLUE}==================================================================${NC}"
