# CẨM NANG QUẢN TRỊ DÀNH CHO GIÁO VIÊN TIN HỌC (NDOJ)
**Trường THPT Nguyễn Du - Huyện Nghi Xuân, Tỉnh Hà Tĩnh**

Tài liệu này hướng dẫn quý thầy cô bộ môn Tin học của Trường THPT Nguyễn Du cách tạo bài tập, tải bộ dữ liệu kiểm thử (testcase), tổ chức các kỳ thi trực tuyến và quản lý học sinh trên hệ thống NDOJ.

---

## 1. Đăng nhập và Phân quyền Giáo viên

### Đăng nhập hệ thống
* **Địa chỉ:** `http://<domain_hoac_ip>/accounts/login/`
* Sử dụng tài khoản Giáo viên được cấp (hoặc tài khoản `admin`).
* Sau khi đăng nhập với quyền Staff / Superuser, thanh menu trên cùng sẽ xuất hiện nút **Quản trị (Admin)** dẫn tới trang quản trị nâng cao `/admin/`.

---

## 2. Hướng dẫn Tạo Bài tập Mới (Problem Creation)

Có 2 cách tạo bài tập: Qua giao diện Web trực quan hoặc qua Trang Quản trị Django.

### Cách 1: Tạo trực tiếp qua giao diện Web (Khuyên dùng)
1. Truy cập menu **Bài tập (Problems)** -> Bấm nút **Tạo bài tập mới (+ New Problem)**.
2. Điền các thông số cơ bản:
   * **Mã bài (Problem Code):** Viết liền không dấu, in hoa hoặc thường (Ví dụ: `TONG_UOC`, `FIBO`, `DOAN_CON`). Mã bài này là duy nhất.
   * **Tên bài (Problem Name):** Tên hiển thị đầy đủ bằng tiếng Việt (Ví dụ: *Tổng các ước số*, *Dãy số Fibonacci*).
   * **Nhóm bài (Group):** Chọn khối lớp tương ứng:
     * `Tin học 10 (GDPT 2018)`
     * `Tin học 11 (GDPT 2018)`
     * `Tin học 12 (GDPT 2018)`
     * `Đội tuyển HSG Tin học`
   * **Thể loại (Types):** Cơ bản, Thuật toán, Quy hoạch động, v.v.
   * **Thời gian chạy tối đa (Time Limit):** Thông thường đặt `1.0` giây (C++ chạy ~10^8 phép tính/giây, Python ~10^7 phép tính/giây).
   * **Bộ nhớ tối đa (Memory Limit):** Mặc định `65536` KB (64 MB) hoặc `131072` KB (128 MB).
   * **Tổng điểm (Points):** Thường là `100` điểm hoặc `10` điểm.
3. Soạn thảo Đề bài (hỗ trợ Markdown và công thức toán học LaTeX):
   * Định dạng công thức toán nằm giữa hai dấu `~` (Ví dụ: `~1 \le N \le 10^5~`).
   * Sử dụng bảng mẫu Markdown chuẩn:
     ```markdown
     # Tên bài toán

     Mô tả đề bài toán tại đây...

     ## Dữ liệu vào (Input)
     * Dòng đầu tiên chứa số nguyên ~N~...
     
     ## Dữ liệu ra (Output)
     * In ra kết quả theo yêu cầu...

     ## Ví dụ (Sample)
     ### Input
     ```
     5
     ```
     ### Output
     ```
     120
     ```
     ```
4. Bấm **Lưu (Save)**.

---

## 3. Hướng dẫn Đóng gói và Tải lên Bộ Testcase

Mỗi bài tập trên NDOJ được kiểm thử tự động bằng một tập hợp các cặp file input và output.

### Cấu trúc file nén Testcase chuẩn (.ZIP)
Thầy cô chuẩn bị một file nén định dạng `.zip` chứa các file:
```
my_problem.zip
├── init.yml
├── 1.in
├── 1.out
├── 2.in
├── 2.out
├── 3.in
└── 3.out
```

Nội dung file `init.yml` mẫu:
```yaml
checker: standard
test_cases:
  - in: 1.in
    out: 1.out
    points: 30
  - in: 2.in
    out: 2.out
    points: 30
  - in: 3.in
    out: 3.out
    points: 40
```

> [!NOTE]
> * `checker: standard`: Bỏ qua khoảng trắng thừa và dòng trống cuối file (rất phù hợp cho học sinh).
> * `checker: strict`: So sánh chính xác từng ký tự (kể cả khoảng trắng).
> * `checker: floats`: Dành cho các bài toán số thực có sai số (ví dụ $10^{-6}$).

### Tải lên hệ thống
1. Vào trang chi tiết bài toán đã tạo -> Chọn mục **Dữ liệu kiểm thử (Edit Test Data)**.
2. Bấm **Chọn file** và upload file `.zip` vừa đóng gói.
3. Bấm **Upload and Extract**. Máy chấm sẽ tự động nhận diện và cập nhật testcase ngay lập tức!

---

## 4. Tổ chức Kỳ thi (Contests) Trực tuyến

Hệ thống NDOJ hỗ trợ tổ chức các kỳ thi kiểm tra 15 phút, 1 tiết, kiểm tra giữa kỳ, cuối kỳ hoặc thi chọn Đội tuyển HSG.

### Các bước tạo Kỳ thi mới:
1. Vào menu **Kỳ thi (Contests)** -> Bấm **Tạo kỳ thi (+ New Contest)**.
2. Cấu hình thông tin:
   * **Tên kỳ thi:** Ví dụ: *Kiểm tra Giữa kỳ 1 - Tin học 10 (Năm học 2026-2027)*.
   * **Thời gian bắt đầu & kết thúc:** Chọn ngày giờ chính xác.
   * **Thời lượng làm bài (Duration):** Ví dụ `45` phút hoặc `90` phút (thời gian làm bài tính từ lúc học sinh bấm Bắt đầu thi).
   * **Kiểu tính điểm (Scoring Format):**
     * **IOI Format (Khuyên dùng cho THPT):** Học sinh được tính điểm từng testcase, nhiều subtask, nộp nhiều lần không bị phạt điểm thời gian.
     * **ACM-ICPC Format:** Tính điểm bài AC và tính thời gian penalty (dành cho thi đấu tốc độ).
   * **Độ bảo mật (Visibility):**
     * *Public:* Mọi học sinh đều thấy.
     * *Private:* Yêu cầu mật khẩu truy cập (Access Code) để chỉ học sinh trong lớp mới được vào thi.
3. Chọn danh sách các bài tập đưa vào kỳ thi và phân bổ điểm số tương ứng.
4. Bấm **Lưu (Save)**.

---

## 5. Quản lý Tài khoản Học sinh và Chấm lại (Rejudge)

### Tạo tài khoản học sinh hàng loạt
Thầy cô có thể tạo nhanh tài khoản cho học sinh theo định dạng thống nhất:
* Tên đăng nhập: `10a1_nguyenvanan` hoặc mã học sinh.
* Mật khẩu khởi tạo: `thptnd@123` (yêu cầu học sinh đổi mật khẩu sau khi đăng nhập).
* Thầy cô vào trang Quản trị `/admin/auth/user/` để quản lý người dùng hoặc liên hệ kỹ thuật viên để chạy kịch bản import từ file Excel danh sách lớp.

### Chấm lại bài làm (Rejudge)
Trong trường hợp phát hiện bộ testcase bị lỗi hoặc muốn cập nhật thêm test:
1. Sửa và cập nhật lại file testcase của bài tập.
2. Truy cập vào trang chi tiết bài tập -> Vào mục **Các bài nộp (Submissions)**.
3. Bấm nút **Chấm lại tất cả (Rejudge All)**. Hệ thống sẽ tự động đưa toàn bộ bài làm của học sinh vào hàng đợi để chấm lại và cập nhật lại bảng xếp hạng ngay lập tức.
