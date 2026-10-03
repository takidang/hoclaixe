---
name: code-review
description: "Review code thay đổi gần nhất hoặc một thư mục/file: kiến trúc, chất lượng, test, bảo mật."
argument-hint: "[đường dẫn | (trống = git diff hiện tại)]"
---

Chủ trì: technical-director. Kèm security-reviewer nếu đụng tới auth, API, dữ liệu người dùng, AI.

Phạm vi: $ARGUMENTS (trống → `git diff` + file chưa track).

Kiểm tra:
1. Đúng kiến trúc và rules trong `.claude/rules/`; không vi phạm phân lớp.
2. Logic đúng AC; xử lý lỗi, trạng thái loading/rỗng/offline.
3. Có test, test có ý nghĩa (không chỉ test cho có).
4. Không hardcode secret, không gọi Gemini trực tiếp từ app, không log dữ liệu cá nhân.
5. Tương thích web (không dùng `dart:io` ở lớp chung).
6. Dễ đọc: tên rõ, hàm ngắn, không trùng lặp.

Báo cáo: phân mức Must fix / Should fix / Nice to have, kèm file:dòng và đề xuất sửa. Không tự sửa khi chưa được đồng ý.
