---
name: dev-story
description: "Phase 5 — hiện thực một story: lập kế hoạch, code, test, tự kiểm tra theo acceptance criteria."
argument-hint: "<ST-xx>"
---

Story: $ARGUMENTS

1. Đọc `production/stories/$ARGUMENTS.md`, FR, screen spec, ADR liên quan. Chọn agent: flutter-developer (app) hoặc backend-developer (server/AI proxy);
   phần RAG thì có ai-engineer.
2. Kiểm tra story đã "sẵn sàng": AC rõ, phụ thuộc đã xong, spec đủ. Chưa sẵn sàng → báo và dừng.
3. Trình bày kế hoạch: file tạo/sửa, test sẽ viết. Chờ duyệt.
4. Code + test. Chạy `flutter analyze` và `flutter test` (hoặc test backend).
5. Đối chiếu từng acceptance criteria: PASS/FAIL kèm bằng chứng (test nào, chạy tay thế nào).
6. Tóm tắt cách code hoạt động (để cả team hiểu khi bảo vệ). Gợi ý `/code-review` rồi `/story-done $ARGUMENTS`.
Không commit trừ khi được yêu cầu; nếu được yêu cầu, commit message dạng `feat(ST-xx): ...`.
