# NDOJ - Nguyễn Du Online Judge
### Hệ thống Chấm bài Lập trình Trực tuyến Tự động • Trường THPT Nguyễn Du - Hà Tĩnh

<p align="center">
  <img src="dmoj/repo/resources/icons/logo.svg" alt="NDOJ Logo" width="450" />
</p>

<p align="center">
  <b>Nền tảng thi đua, học tập và rèn luyện môn Tin học dành riêng cho học sinh & giáo viên<br/>Trường THPT Nguyễn Du (Huyện Nghi Xuân, Tỉnh Hà Tĩnh)</b><br/>
  <i>Được phát triển và tùy biến dựa trên nền tảng mã nguồn mở <b>VNOJ (Vietnam Online Judge) / DMOJ</b></i>
</p>

---

## 🌟 Giới thiệu Hệ thống

**NDOJ (Nguyen Du Online Judge)** là hệ thống kiểm tra và chấm bài lập trình trực tuyến tự động được thiết kế phục vụ công tác dạy và học môn Tin học theo **Chương trình Giáo dục phổ thông 2018**, đồng thời tạo sân chơi bồi dưỡng tư duy giải thuật cho các thế hệ học sinh và thành viên **Đội tuyển Học sinh giỏi Tin học** của Trường THPT Nguyễn Du trên quê hương Đại thi hào Nguyễn Du.

### 🚀 Tính năng Nổi bật
* **Chấm bài tự động thời gian thực (Real-time Judging):** Tích hợp WebSocket (`wsevent`), học sinh quan sát kết quả chấm từng testcase (AC, WA, TLE, MLE, RTE) tức thì mà không cần tải lại trang.
* **Hỗ trợ đa ngôn ngữ lập trình chuẩn:**
  * **C++ (C++17, C++20):** Tối ưu cho thi HSG Tỉnh, HSG Quốc gia.
  * **Python 3:** Ngôn ngữ chính khóa chương trình Tin học 10, 11 GDPT 2018.
  * **Free Pascal (FPC):** Ngôn ngữ nhập môn truyền thống.
  * **Java:** Lập trình hướng đối tượng.
* **Môi trường cách ly máy chấm an toàn (Sandbox Security):** Máy chấm (`judge-server`) vận hành trong môi trường cgroups & namespaces của Linux, kiểm soát nghiêm ngặt thời gian chạy (CPU Time) và bộ nhớ (RAM), ngăn chặn triệt để mã độc.
* **Tổ chức Kỳ thi (Contest) chuyên nghiệp:**
  * Hỗ trợ định dạng tính điểm **IOI** (tính điểm từng subtask) và **ACM-ICPC** (tính bài AC và thời gian penalty).
  * Chế độ đóng băng bảng xếp hạng (Scoreboard freeze) tạo kịch tính cho kỳ thi.
  * Kỳ thi riêng tư (Private) bảo vệ bằng mật khẩu dành cho từng lớp học.
* **Bộ bài tập mẫu tích hợp sẵn:** Ngân hàng bài tập từ cơ bản đến nâng cao chia theo khối lớp 10, 11, 12 và chuyên đề bồi dưỡng HSG.
* **Giao diện thuần Việt & Nhận diện THPT Nguyễn Du:** Logo, màu sắc học đường, cẩm nang hướng dẫn nộp bài tiếng Việt thân thiện với học sinh.

---

## 🏗️ Kiến trúc Hệ thống (Architecture)

Hệ thống được đóng gói hoàn chỉnh bằng **Docker Compose** bao gồm 8 container dịch vụ phối hợp nhịp nhàng:

| Dịch vụ | Tên Container | Mô tả vai trò |
| :--- | :--- | :--- |
| **Site Web** | `ndoj_site` | Backend Django 3.2 + uWSGI xử lý logic web, quản lý đề, tài khoản |
| **Database** | `ndoj_mysql` | Cơ sở dữ liệu MariaDB 10.11 lưu trữ toàn bộ người dùng, bài tập, bài nộp |
| **Cache & Queue** | `ndoj_redis` | Bộ nhớ tạm Redis và trung gian truyền tin cho Celery |
| **Async Worker** | `ndoj_celery` | Xử lý tác vụ bất đồng bộ (chấm lại hàng loạt, tính điểm xếp hạng) |
| **Judge Bridge** | `ndoj_bridged` | Cầu nối socket bảo mật giao tiếp giữa trang web và các máy chấm |
| **WebSocket** | `ndoj_wsevent` | Node.js Daemon truyền tải tiến độ chấm thi trực tiếp tới trình duyệt |
| **Reverse Proxy** | `ndoj_nginx` | Máy chủ web Nginx điều phối luồng, nén Gzip, cache Static/Media |
| **Judge Engine** | `ndoj_judge_1` | Máy chấm Docker Tier 1 tự động thực thi code học sinh trong sandbox |

---

## ⚡ Hướng dẫn Khởi chạy Nhanh

### Cách 1: Cài đặt 1-Chạm lên Máy chủ VPS Linux (Khuyến nghị cho trường)
Chỉ cần chuẩn bị một máy chủ Ubuntu (20.04 / 22.04 / 24.04 LTS), chạy đúng 1 lệnh duy nhất:
```bash
sudo bash scripts/setup_vps.sh
```
Toàn bộ quá trình cài đặt Docker, cấu hình tường lửa, sinh mật khẩu an toàn, khởi chạy các container và nạp dữ liệu mẫu sẽ diễn ra hoàn toàn tự động trong khoảng 3 - 5 phút!

* Để bật SSL HTTPS miễn phí cho tên miền của trường (ví dụ: `oj.thptnguyendu-hatinh.edu.vn`):
```bash
sudo bash scripts/setup_ssl.sh oj.thptnguyendu-hatinh.edu.vn
```

### Cách 2: Chạy thử nghiệm trên Máy tính cá nhân (Docker Desktop)
1. Cài đặt [Docker Desktop](https://www.docker.com/products/docker-desktop/) (bật chế độ WSL2 trên Windows).
2. Mở Terminal / PowerShell tại thư mục `dmoj`:
```bash
cd dmoj
./scripts/initialize
docker compose build
docker compose up -d
./scripts/migrate
./scripts/copy_static
./scripts/seed_ndoj
```
3. Mở trình duyệt truy cập: `http://localhost/`.

---

## 🔐 Tài khoản Quản trị Mặc định (Default Admin)

* **URL Đăng nhập:** `http://<domain_hoac_ip>/accounts/login/`
* **Tài khoản:** `admin`
* **Mật khẩu:** `NguyenDu@2026`
* **Email:** `admin@ndoj.edu.vn`

*(Quý thầy cô vui lòng đổi lại mật khẩu ngay sau khi đăng nhập lần đầu tiên tại trang cá nhân)*.

---

## 📚 Tài liệu Hướng dẫn Chi tiết

Toàn bộ tài liệu nghiệp vụ đã được biên soạn đầy đủ trong thư mục `DOCS/`:

* 📖 **[Hướng dẫn Triển khai VPS & Vận hành Kỹ thuật](DOCS/HUONG_DAN_TRIEN_KHAI_VPS.md)**: Hướng dẫn chi tiết mua VPS, trỏ DNS, cài đặt 1-chạm, backup và tối ưu RAM Swap.
* 👨‍🏫 **[Cẩm nang Quản trị dành cho Giáo viên](DOCS/HUONG_DAN_QUAN_TRI_GIAO_VIEN.md)**: Hướng dẫn tạo bài tập mới, soạn thảo Markdown, upload testcase zip, tổ chức kỳ thi, quản lý học sinh và chấm lại bài.
* 👨‍🎓 **[Cẩm nang Hướng dẫn Học sinh làm bài](DOCS/HUONG_DAN_HOC_SINH.md)**: Hướng dẫn học sinh đăng ký, quy tắc nhập xuất (stdin/stdout), mẫu code C++, Python, Pascal và ý nghĩa các kết quả AC, WA, TLE, MLE, CE.

---

## 🛠️ Quản lý Dịch vụ Thường dùng

```bash
cd dmoj

# Xem trạng thái các container
docker compose ps

# Khởi động lại toàn bộ
docker compose restart

# Xem log kiểm tra máy chấm
docker compose logs -f judge

# Sao lưu cơ sở dữ liệu và dữ liệu bài tập
./scripts/backup

# Cập nhật hệ thống an toàn không mất dữ liệu
bash ../scripts/update.sh
```

---

## 🤝 Đóng góp & Lời cảm ơn

* Hệ thống NDOJ được phát triển dựa trên nền tảng nguồn mở của dự án [VNOJ (VNOI-Admin)](https://github.com/VNOI-Admin) và dự án [DMOJ](https://github.com/DMOJ).
* Xin trân trọng cảm ơn cộng đồng Tin học trẻ Việt Nam (VNOI) và các thầy cô giáo tổ Tin học - Ngoại ngữ Trường THPT Nguyễn Du, Hà Tĩnh đã đồng hành và xây dựng sân chơi bổ ích cho học sinh!

---
© 2026 **Trường THPT Nguyễn Du - Huyện Nghi Xuân, Tỉnh Hà Tĩnh**.
Motto: *"Rèn luyện tư duy thuật toán - Chinh phục đỉnh cao Tin học"*
