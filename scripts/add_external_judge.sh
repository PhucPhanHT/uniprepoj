#!/bin/bash
# ==============================================================================
# HƯỚNG DẪN VÀ KỊCH BẢN KẾT NỐI MÁY CHẤM PHỤ (EXTERNAL JUDGE) VÀO NDOJ
# Trường THPT Nguyễn Du - Huyện Nghi Xuân, Tỉnh Hà Tĩnh
# ==============================================================================

SERVER_IP=${1:-"your-server-ip"}
JUDGE_NAME=${2:-"ndoj_judge_lab_1"}
JUDGE_KEY=${3:-"ndoj_secret_judge_key_2026"}

cat <<EOF
===============================================================================
  KẾT NỐI MÁY CHẤM NGOÀI (EXTERNAL JUDGE) VÀO NDOJ - THPT NGUYỄN DU
===============================================================================

Quý thầy cô hoặc kỹ thuật viên có thể tận dụng máy tính tại phòng Tin học của
trường (chạy Ubuntu Linux hoặc Docker trên Windows WSL2) để làm máy chấm phụ!

Các bước thực hiện trên máy chấm phụ:

1. Đảm bảo máy tính đã cài Docker.
2. Chuẩn bị thư mục /problems để đồng bộ dữ liệu test (hoặc nfs/sshfs).
3. Tạo file judge.yml với nội dung:

id: "$JUDGE_NAME"
key: "$JUDGE_KEY"
problem_storage_globs:
  - /problems/*

4. Chạy lệnh Docker sau để kết nối máy chấm về máy chủ NDOJ trung tâm ($SERVER_IP):

docker run -d \\
  --name $JUDGE_NAME \\
  --restart always \\
  --cap-add=SYS_PTRACE \\
  -v /path/to/problems:/problems \\
  -v /path/to/judge.yml:/judge.yml:ro \\
  dmoj/judge-tier1:latest \\
  run -c /judge.yml $SERVER_IP:9999 $JUDGE_NAME $JUDGE_KEY

5. Đăng ký máy chấm trên trang Admin NDOJ:
   Truy cập: http://$SERVER_IP/admin/judge/judge/add/
   - Name: $JUDGE_NAME
   - Auth Key: $JUDGE_KEY
   - Is blocked: bỏ chọn
   - Bấm "Save"

Máy chấm sẽ tự động kết nối và hiển thị trạng thái Online màu xanh lá trên trang /status/!
===============================================================================
EOF
