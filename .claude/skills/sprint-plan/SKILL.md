---
name: sprint-plan
description: "Lập kế hoạch sprint mới hoặc cập nhật sprint hiện tại theo năng lực thực tế của team."
argument-hint: "[new | update | close]"
---

Chủ trì: project-manager. Chế độ: $ARGUMENTS (mặc định `new`).

- `new`: đọc backlog, velocity sprint trước (nếu có), năng lực trong project-context.md, mốc thời gian.
  Đề xuất sprint goal + danh sách story, chia đều cho 2 thành viên. Sprint 5 (tuần 9–10) chỉ dành cho ổn định, test, báo cáo.
  Ghi `production/sprints/sprint-<n>.md` theo `docs/templates/sprint-template.md` sau khi duyệt.
- `update`: cập nhật trạng thái story, phát hiện story có nguy cơ trễ, đề xuất cắt/đẩy.
- `close`: tính velocity, story xong/chưa xong, cập nhật burndown, gợi ý chạy `/retro`.
Luôn cập nhật `production/status.md` (hỏi trước).
