#!/bin/bash
# ==============================================================================
# KỊCH BẢN CẤU HÌNH SSL HTTPS (LET'S ENCRYPT) CHO HỆ THỐNG NDOJ
# Trường THPT Nguyễn Du - Huyện Nghi Xuân, Tỉnh Hà Tĩnh
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[LỖI] Vui lòng chạy kịch bản này với quyền root: sudo bash $0 domain.edu.vn${NC}"
  exit 1
fi

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
  echo -e "${RED}[LỖI] Thiếu tên miền! Cú pháp: sudo bash $0 <ten_mien>${NC}"
  echo -e "Ví dụ: sudo bash $0 oj.thptnguyendu-hatinh.edu.vn"
  exit 1
fi

echo -e "${BLUE}>> Đang chuẩn bị cấp chứng chỉ SSL miễn phí cho tên miền: ${YELLOW}$DOMAIN${NC}"

# Cài đặt certbot
apt-get update -qq
apt-get install -y -qq certbot

PROJECT_DIR="$(cd "$(dirname "$(dirname "$0")")" && pwd)"
DMOJ_DIR="$PROJECT_DIR/dmoj"

cd "$DMOJ_DIR"

# Tạm dừng Nginx container để giải phóng cổng 80 cho certbot standalone
echo -e "${YELLOW}>> Đang tạm dừng Nginx container để xác thực tên miền...${NC}"
docker compose stop nginx

# Cấp chứng chỉ SSL bằng certbot standalone
certbot certonly --standalone -d "$DOMAIN" --non-interactive --agree-tos -m admin@ndoj.edu.vn

echo -e "${GREEN}>> Cấp chứng chỉ SSL thành công!${NC}"

# Cập nhật site.env
sed -i "s|HOST=.*|HOST=$DOMAIN|g" environment/site.env
sed -i "s|SITE_FULL_URL=.*|SITE_FULL_URL=https://$DOMAIN/|g" environment/site.env
sed -i "s|MEDIA_URL=.*|MEDIA_URL=https://$DOMAIN/|g" environment/site.env

# Tạo cấu hình Nginx SSL
cat > nginx/conf.d/nginx.conf <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;
    client_max_body_size 128M;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    add_header X-UA-Compatible "IE=Edge,chrome=1";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    charset utf-8;
    try_files \$uri @icons;
    error_page 502 504 /502.html;

    location ~ ^/502\.html$|^/logo\.png$|^/logo\.svg$|^/robots\.txt$ {
        root /assets/;
    }

    location @icons {
        root /assets/resources/icons/;
        log_not_found off;
        error_page 403 = @uwsgi;
        error_page 404 = @uwsgi;
    }

    location @uwsgi {
        uwsgi_read_timeout 600;
        uwsgi_send_timeout 600;
        uwsgi_pass site:8000;
        include uwsgi_params;
        uwsgi_param SERVER_SOFTWARE nginx/\$nginx_version;
        uwsgi_param HTTP_HOST \$http_host;
        uwsgi_param X-Real-IP \$remote_addr;
        uwsgi_param X-Forwarded-For \$proxy_add_x_forwarded_for;
        uwsgi_param X-Forwarded-Proto https;
        uwsgi_param UWSGI_SCHEME https;
    }

    location /static {
        gzip_static on;
        expires max;
        root /assets/;
    }

    location /martor {
        root /media/;
    }

    location /pdf {
        root /media/;
    }

    location /submission_file {
        root /media/;
    }

    location /userdatacache {
        internal;
        root /;
    }

    location /contestdatacache {
        internal;
        root /;
    }

    location /event/ {
        proxy_pass http://wsevent:15100/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 86400;
    }

    location /channels/ {
        proxy_read_timeout 120;
        proxy_pass http://wsevent:15102/;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Thêm volume SSL vào docker-compose.yml nếu chưa có
if ! grep -q "/etc/letsencrypt/" docker-compose.yml; then
    sed -i '/- \.\/nginx\/conf\.d\/:/a \      - /etc/letsencrypt/:/etc/letsencrypt/:ro' docker-compose.yml
    sed -i 's/"\${HTTP_PORT:-80}:80"/"\${HTTP_PORT:-80}:80"\n      - "443:443"/' docker-compose.yml
fi

echo -e "${YELLOW}>> Đang khởi động lại Nginx và cập nhật cấu hình HTTPS...${NC}"
docker compose up -d nginx site

echo -e "\n${GREEN}🎉 Chúc mừng! Website NDOJ hiện đã hoạt động an toàn với giao thức HTTPS:${NC}"
echo -e "${BLUE}https://$DOMAIN/${NC}\n"
