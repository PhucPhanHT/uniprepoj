# HƯỚNG DẪN TRIỂN KHAI HỆ THỐNG NDOJ LÊN MÁY CHỦ LINUX (VPS)
**Trường THPT Nguyễn Du - Huyện Nghi Xuân, Tỉnh Hà Tĩnh**

Tài liệu này hướng dẫn chi tiết dành cho giáo viên phụ trách kỹ thuật / công nghệ thông tin của Trường THPT Nguyễn Du để cài đặt và vận hành hệ thống **NDOJ (Nguyen Du Online Judge)** lên máy chủ Cloud VPS một cách an toàn, bảo mật và ổn định.

---

## 1. Yêu cầu Cấu hình Máy chủ (VPS Requirements)

| Tiêu chí | Cấu hình tối thiểu | Cấu hình khuyến nghị (Cho toàn trường) |
| :--- | :--- | :--- |
| **Hệ điều hành** | Ubuntu 22.04 LTS / 24.04 LTS 64-bit | Ubuntu 22.04 LTS / 24.04 LTS 64-bit |
| **CPU** | 2 vCPU | 4 vCPU |
| **RAM** | 2 GB (+ 2GB Swap) | 4 GB - 8 GB RAM |
| **Ổ cứng (SSD)** | 25 GB SSD | 50 GB - 80 GB NVMe SSD |
| **Băng thông** | 100 Mbps | 1 Gbps (Không giới hạn lưu lượng) |

> [!TIP]
> **Các nhà cung cấp máy chủ uy tín:**
> * **Trong nước:** Vietnix, TinoHost, VNPT Cloud, Viettel IDC, BKNS (tốc độ truy cập mạng nội địa cực nhanh cho học sinh tại Hà Tĩnh).
> * **Quốc tế:** DigitalOcean (Singapore), Linode/Akamai, Vultr, Hetzner, AWS Lightsail.

---

## 2. Hướng dẫn Cài đặt 1-Chạm (1-Click Automated Setup)

Hệ thống NDOJ đã được đóng gói sẵn kịch bản tự động hóa toàn bộ quy trình: cài Docker, tạo mạng container, sinh mật khẩu bảo mật, cấu hình máy chấm và nạp sẵn ngân hàng bài tập mẫu.

### Bước 1: Kết nối vào VPS qua SSH
Sử dụng Terminal (trên Linux/macOS) hoặc PowerShell / PuTTY / MobaXterm (trên Windows):
```bash
ssh root@<IP_MÁY_CHỦ_CỦA_BẠN>
```

### Bước 2: Tải mã nguồn NDOJ về VPS
Nếu máy chủ mới chưa có Git, hãy cài đặt nhanh:
```bash
apt-get update && apt-get install -y git
```

Sau đó clone mã nguồn NDOJ (kèm theo toàn bộ submodule VNOJ):
```bash
git clone --recursive https://github.com/PhucPhanHT/NDOJ.git /opt/ndoj
# Hoặc copy toàn bộ thư mục D:\Project\NDOJ từ máy tính lên VPS thư mục /opt/ndoj
cd /opt/ndoj
```

### Bước 3: Chạy kịch bản cài đặt tự động
Chỉ cần thực hiện đúng một lệnh:
```bash
sudo bash scripts/setup_vps.sh
```

Kịch bản sẽ tự động thực hiện:
1. Cài đặt Docker Engine & Docker Compose chính thức.
2. Mở cổng tường lửa UFW (Port 22 SSH, 80 HTTP, 443 HTTPS, 9999 Bridge Judge).
3. Tự động sinh chuỗi mã hóa ngẫu nhiên an toàn cho Database và Django `SECRET_KEY`.
4. Khởi động 8 container dịch vụ: `ndoj_mysql`, `ndoj_redis`, `ndoj_site`, `ndoj_celery`, `ndoj_bridged`, `ndoj_wsevent`, `ndoj_nginx`, `ndoj_judge_1`.
5. Tự động chạy Migration bảng dữ liệu, biên dịch giao diện tiếng Việt và nạp bộ đề thi mẫu cho THPT Nguyễn Du.
6. Tạo tài khoản Quản trị viên Super Admin mặc định:
   * **Tài khoản:** `admin`
   * **Mật khẩu:** `NguyenDu@2026`
   * **Email:** `admin@ndoj.edu.vn`

---

## 3. Cấu hình Tên miền và Bật SSL HTTPS Miễn phí

Để học sinh và giáo viên truy cập qua tên miền chính thức của trường (ví dụ: `oj.thptnguyendu-hatinh.edu.vn` hoặc `ndoj.edu.vn`):

### Bước 1: Cấu hình bản ghi DNS
Đăng nhập trang quản lý tên miền và tạo bản ghi:
* **Loại bản ghi (Record Type):** `A`
* **Tên (Host):** `oj` (hoặc `@` nếu dùng tên miền gốc)
* **Giá trị (Value / Points to):** Địa chỉ IP của VPS

### Bước 2: Chạy lệnh cấp chứng chỉ SSL Let's Encrypt tự động
Sau khi DNS đã trỏ về IP của máy chủ, trên VPS chạy lệnh:
```bash
cd /opt/ndoj
sudo bash scripts/setup_ssl.sh oj.thptnguyendu-hatinh.edu.vn
```
Hệ thống sẽ tự động đăng ký chứng chỉ SSL với Let's Encrypt, cấu hình Nginx sang HTTPS (HTTP/2) và tự động gia hạn khi hết hạn.

---

## 4. Quản lý và Vận hành Hằng ngày

### Khởi động / Dừng / Khởi động lại hệ thống
```bash
cd /opt/ndoj/dmoj

# Xem trạng thái các container
docker compose ps

# Khởi động toàn bộ hệ thống
docker compose up -d

# Tạm dừng toàn bộ hệ thống
docker compose down

# Khởi động lại khi có thay đổi cấu hình
docker compose restart
```

### Xem Log thời gian thực để kiểm tra hoạt động
```bash
# Xem log máy chấm (judge)
docker compose logs -f judge

# Xem log web chính (site)
docker compose logs -f site

# Xem log WebSocket cập nhật trực tiếp (wsevent)
docker compose logs -f wsevent
```

### Sao lưu (Backup) Dữ liệu
Dữ liệu thi đua và bài làm của học sinh rất quan trọng. Bạn có thể sao lưu thủ công bất cứ lúc nào:
```bash
cd /opt/ndoj/dmoj
./scripts/backup
```
Toàn bộ cơ sở dữ liệu MySQL và thư mục testcase sẽ được nén vào thư mục `dmoj/backups/`.

---

## 5. Tối ưu Bộ nhớ RAM cho VPS (Tạo Swap)
Nếu thuê VPS gói 2GB RAM, bạn nên bật 2GB - 4GB Swap để tránh tình trạng tràn RAM khi đông học sinh cùng nộp bài thi:
```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```
Kiểm tra lại dung lượng: `free -h`.
