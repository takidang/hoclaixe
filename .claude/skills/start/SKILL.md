---
name: start
description: "Khởi động dự án lần đầu — điền bối cảnh, team, mốc thời gian, chọn hướng đi. Dùng ở phiên đầu tiên."
---

Mục tiêu: điền đủ `.claude/docs/project-context.md` để mọi agent có cùng bối cảnh.

1. Đọc `.claude/docs/project-context.md`. Liệt kê các mục còn `[ĐIỀN ...]` hoặc `[CHỌN ...]`.
2. Hỏi người dùng từng nhóm (mỗi lượt tối đa 3 câu):
   - Tên app, tên 2 thành viên, ai mạnh mảng nào, số giờ/tuần mỗi người.
   - Hạn nộp và bảo vệ đồ án LTTTBDD; yêu cầu riêng của từng giảng viên (format báo cáo, có cần backend không, có cần đăng nhập không…).
   - Kinh nghiệm hiện có: đã dùng Flutter chưa, Firebase chưa, Git chưa.
3. Tóm tắt lại, xin phép ghi vào `project-context.md`.
4. Tạo `production/status.md` (phase 0 xong) và `production/risks.md` (rủi ro ban đầu) — hỏi trước khi ghi.
5. Gợi ý bước tiếp theo: `/discovery`.
