---
name: tam-nghi
description: "Kết thúc phiên làm việc. Dùng khi người dùng nói \"tạm nghỉ\", \"tạm dừng\", \"nghỉ đây\", \"hết phiên\": cập nhật production/status.md, rồi commit và push mọi thay đổi còn lại lên nhánh hiện tại."
---

Người dùng nói "tạm nghỉ" = **đã đồng ý commit và push** những gì làm trong phiên (ngoại lệ đã thống nhất với quy tắc
"không commit khi chưa được yêu cầu" trong CLAUDE.md). Làm lần lượt, không hỏi lại trừ khi gặp điểm dừng bên dưới.

1. **Hoàn tất việc đang dở** đến điểm an toàn (không để file sửa dở, script chạy dở). Nếu đang có agent/lệnh chạy nền:
   báo người dùng và dừng chúng trước khi commit.
2. **Cập nhật `production/status.md`** (theo CLAUDE.md — cuối mỗi phiên):
   - `**Cập nhật**:` ngày hôm nay; phase/sprint hiện tại.
   - "Đã xong": thêm các việc của phiên này (ngắn, có đường dẫn file).
   - "Việc tiếp theo (phiên sau bắt đầu từ đây)": sắp xếp lại theo ưu tiên.
   - "Phân công" và "Blocker / cần bổ sung": cập nhật nếu có thay đổi.
3. **Kiểm tra trước khi commit**:
   - `git status --short` — đọc danh sách. Chỉ đưa vào commit file thuộc dự án (code, tài liệu, dữ liệu đã trích xuất,
     `.claude/`). **Dừng và hỏi** nếu thấy file lạ ở thư mục gốc, file nặng bất thường (> 20 MB), file nhị phân không rõ
     nguồn, hoặc bất cứ thứ gì giống bí mật (`.env`, key, `*.jks`, service account) — không bao giờ commit những thứ này.
   - Nếu phiên có sửa dữ liệu trong `data/`: chạy `python tools/validate_data/validate_questions.py` và/hoặc
     `python tools/validate_data/validate_signs.py`; FAIL → báo người dùng, không commit dữ liệu hỏng.
4. **Commit**: thêm đúng các file đã kiểm (`git add <đường dẫn>`, tránh `git add -A` khi có file lạ). Message tiếng Anh
   theo dạng `<type>: <tóm tắt>` (docs / data / tools / feat / fix / chore), mô tả ngắn các việc chính của phiên,
   kết thúc bằng dòng attribution theo hướng dẫn hệ thống nếu có.
5. **Push** lên nhánh hiện tại (`git push`). Nếu nhánh hiện tại là `master` → **không push**, hỏi người dùng
   (master chỉ nhận bản ổn định qua merge). Push lỗi (mạng, conflict) → báo nguyên nhân, không dùng `--force`.
6. **Báo lại ngắn gọn** cho người dùng:
   - Commit nào (hash + message), đã push lên nhánh nào — hoặc "không có gì để commit".
   - 2–3 việc đầu tiên của phiên sau (lấy từ status.md).
   - Việc người dùng cần làm ngoài máy (gửi file cho Kiệt, nộp giấy tờ…) nếu có.
