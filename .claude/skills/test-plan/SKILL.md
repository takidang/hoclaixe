---
name: test-plan
description: "Phase 6 — lập test plan, bảng test case truy vết yêu cầu, chạy và ghi kết quả."
argument-hint: "[plan | cases | run | report]"
---

Chủ trì: qa-engineer. Chế độ: $ARGUMENTS (mặc định `plan`).

- `plan`: `docs/test/test-plan.md` theo `docs/templates/test-plan-template.md`.
- `cases`: sinh test case từ SRS (mỗi FR ít nhất 1 case thường + 1 case biên/lỗi) → `docs/test/test-cases.md`, kèm ma trận truy vết FR ↔ TC.
  Bắt buộc có các test sau (xem `docs/srs/requirements-draft.md`):
  - Đáp án đã chọn được giữ nguyên khi: chuyển câu, quay lại câu cũ, xoay màn hình, app vào nền, tắt app giữa bài, nộp bài.
  - Trượt khi sai câu điểm liệt dù đủ điểm; đúng số câu và thời gian theo hạng.
  - Chatbot: câu ngoài phạm vi, câu mơ hồ, prompt injection, hết quota, mất mạng.
  - Nhận diện: ảnh rõ, ảnh mờ/tối/nghiêng, ảnh có nhiều biển, ảnh không có biển, từ chối quyền camera, chọn ảnh thư viện, máy không mạng.
  - labels.txt khớp danh mục biển báo.
- `run`: chạy `flutter test --coverage` (và integration test nếu có); hướng dẫn người dùng chạy test thủ công trên máy thật, nhập kết quả.
- `report`: `docs/test/test-report.md` — số case pass/fail, độ phủ code, bug còn mở theo mức độ, kết luận. Số liệu dùng cho báo cáo.
