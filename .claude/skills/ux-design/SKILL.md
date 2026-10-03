---
name: ux-design
description: "Phase 3 — user flow, danh sách màn hình, spec từng màn hình, design system."
argument-hint: "[flow | screen <tên> | design-system | all]"
---

Chủ trì: ux-designer. Yêu cầu: $ARGUMENTS

1. Đọc SRS và các spec đã có trong `docs/ux/`.
2. `flow`: vẽ user flow bằng Mermaid trong `docs/ux/user-flows.md`.
3. `screen <tên>`: spec theo `docs/templates/screen-spec-template.md` → `docs/ux/screens/<tên>.md`.
   Bao gồm wireframe dạng ASCII, mọi trạng thái (loading/rỗng/lỗi/offline), điều hướng, FR liên quan.
4. `design-system`: `docs/ux/design-system.md` — màu (light/dark), typography, spacing, component dùng chung, breakpoint web.
5. Bắt buộc có spec cho: màn hình camera/nhận diện (3 trạng thái kết quả theo README 3.4),
   hộp thoại cảnh báo AI lần đầu, khối câu trả lời chatbot (dòng cảnh báo + Kiểm chứng + trích dẫn + Báo sai), màn hình Giới thiệu/miễn trừ.
6. Người dùng có thể vẽ lại trên Figma từ spec này để đưa ảnh vào báo cáo.
7. Hỏi trước khi ghi mỗi file.
