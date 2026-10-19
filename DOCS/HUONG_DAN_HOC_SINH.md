# CẨM NANG HƯỚNG DẪN HỌC SINH LÀM BÀI TRÊN NDOJ
**Trường THPT Nguyễn Du - Huyện Nghi Xuân, Tỉnh Hà Tĩnh**

Chào mừng các bạn học sinh Trường THPT Nguyễn Du đến với hệ thống luyện tập và chấm bài tự động **NDOJ (Nguyen Du Online Judge)**!

Tài liệu này sẽ hướng dẫn các bạn từng bước từ đăng ký tài khoản, cách viết code đúng chuẩn trên các ngôn ngữ phổ biến (C++, Python, Pascal) đến cách nộp bài và khắc phục các lỗi thường gặp.

---

## 1. Đăng ký & Đăng nhập

1. Truy cập vào website NDOJ của trường (địa chỉ do thầy cô bộ môn cung cấp).
2. Nếu chưa có tài khoản:
   * Bấm nút **Đăng ký (Register)** ở góc trên bên phải.
   * Điền Tên đăng nhập (Khuyến nghị: `ten_lop`, ví dụ: `nam_10a1`, `linh_11a3`).
   * Điền Email (để nhận thông báo và lấy lại mật khẩu khi quên) và Mật khẩu.
3. Nếu thầy cô đã cấp tài khoản theo danh sách lớp, các bạn bấm **Đăng nhập (Log in)** và nên tiến hành đổi mật khẩu cá nhân ngay lần đầu tiên.

---

## 2. Quy tắc Nhập / Xuất Dữ liệu (I/O Rules) Cực kỳ Quan trọng!

Hệ thống chấm bài tự động hoạt động bằng cách: Đưa dữ liệu đầu vào qua **Luồng vào chuẩn (Standard Input - stdin)** và đọc kết quả từ **Luồng ra chuẩn (Standard Output - stdout)** của chương trình bạn nộp.

> [!CAUTION]
> **NHỮNG LỖI CẤM KỴ:**
> * ❌ **KHÔNG** in ra các câu nhắc nhập liệu như: `Nhap a: `, `Nhap N = `, `Ket qua la: `.
> * ❌ **KHÔNG** sử dụng các lệnh dừng màn hình như: `system("pause")`, `getch()`, `readkey`.
> * ❌ **KHÔNG** dùng lệnh đọc file `freopen("INPUT.INP", "r", stdin)` trừ khi đề bài yêu cầu rõ ràng.

---

## 3. Khuôn mẫu Mã nguồn Chuẩn cho Từng Ngôn ngữ

### 🔷 Ngôn ngữ C++ (C++17 / C++20) - Khuyên dùng cho HSG
```cpp
#include <iostream>

using namespace std;

int main() {
    // Tối ưu tốc độ nhập xuất (rất quan trọng cho các bài test lớn)
    ios_base::sync_with_stdio(false);
    cin.tie(NULL);

    long long a, b;
    if (cin >> a >> b) {
        cout << a + b << "\n";
    }

    return 0;
}
```

### 🐍 Ngôn ngữ Python 3 - Khuyên dùng cho Tin học 10, 11 GDPT 2018
```python
import sys

def main():
    # Đọc dữ liệu nhanh qua sys.stdin
    input_data = sys.stdin.read().split()
    if len(input_data) >= 2:
        a = int(input_data[0])
        b = int(input_data[1])
        print(a + b)

if __name__ == "__main__":
    main()
```
*Với các bài nhập từng dòng đơn giản:*
```python
a, b = map(int, input().split())
print(a + b)
```

### 🟦 Ngôn ngữ Free Pascal (FPC)
```pascal
program SumAB;
var
    a, b: int64;
begin
    readln(a, b);
    writeln(a + b);
end.
```

---

## 4. Bảng Tra cứu Kết quả Chấm bài

Sau khi bấm nút **Nộp bài (Submit)**, hệ thống sẽ tự động chuyển bạn đến trang bài nộp và cập nhật trạng thái chấm theo thời gian thực (Real-time WebSocket):

| Ký hiệu | Tên tiếng Anh | Ý nghĩa & Cách xử lý |
| :---: | :--- | :--- |
| **AC** | **Accepted** | **Chính xác 100%!** Bạn đã giải đúng bài toán và đạt trọn vẹn điểm số của testcase đó. |
| **WA** | **Wrong Answer** | **Kết quả sai.** Thuật toán chưa đúng với dữ liệu đề bài, hoặc in sai định dạng (thừa/thiếu dấu cách, in hoa/thường khác đề). |
| **TLE** | **Time Limit Exceeded** | **Chạy quá thời gian cho phép.** Thuật toán của bạn có độ phức tạp quá lớn (ví dụ $O(N^2)$ thay vì $O(N \log N)$), hoặc bị lặp vô tận `while (true)`. |
| **MLE** | **Memory Limit Exceeded** | **Vượt quá bộ nhớ.** Khai báo mảng quá lớn (ví dụ mảng `int a[100000000]`). |
| **RTE** | **Runtime Error** | **Lỗi khi thực thi.** Các nguyên nhân thường gặp: chia cho số 0, truy cập mảng ngoài chỉ số (ví dụ khai báo mảng 100 mà truy cập `a[105]`), hoặc đệ quy quá sâu gây tràn stack. |
| **CE** | **Compile Error** | **Lỗi biên dịch.** Code của bạn bị sai cú pháp (thiếu dấu `;`, khai báo sai kiểu biến, gọi hàm không tồn tại). Hãy bấm vào chữ **CE** để đọc thông báo lỗi từ trình biên dịch! |

---

## 5. Mẹo Rèn luyện Đạt Điểm Cao

1. **Luôn bắt đầu từ các bài tập cơ bản:** Luyện tập với các bài trong mục `Tin học 10` trước để thành thạo kỹ năng nhập xuất dữ liệu và cú pháp.
2. **Đọc kỹ giới hạn dữ liệu ($N$):**
   * Nếu $N \le 20$: Có thể dùng thuật toán quay lui (Backtracking).
   * Nếu $N \le 10^3$: Có thể dùng thuật toán $O(N^2)$.
   * Nếu $N \le 10^5 - 10^6$: Cần dùng thuật toán $O(N)$ hoặc $O(N \log N)$.
3. **Chú ý kiểu dữ liệu số nguyên:**
   * Kiểu `int` trong C++ chỉ chứa được số đến khoảng $2 \times 10^9$. Nếu kết quả tính toán hoặc tích các số vượt qua ngưỡng này, hãy dùng kiểu `long long`.
4. **Kiểm tra các trường hợp đặc biệt (Edge Cases):** $N = 0$, $N = 1$, số âm, mảng rỗng, v.v.

*Chúc toàn thể các bạn học sinh Trường THPT Nguyễn Du học tập thật tốt và gặt hái nhiều điểm AC trên NDOJ!*
