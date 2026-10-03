---
name: write-srs
description: "Phase 2 — viết đặc tả yêu cầu (SRS), use case, user story và acceptance criteria."
argument-hint: "[full | module-a | module-b | update <FR-xx>]"
---

Chủ trì: business-analyst. Review: product-director, qa-engineer.

Phạm vi: $ARGUMENTS (mặc định `full`).

1. Đọc `docs/srs/vision.md` và project-context.md.
2. Liệt kê actor và danh sách use case; hỏi người dùng xác nhận trước khi viết chi tiết.
3. Với mỗi use case: đặc tả theo `docs/templates/use-case-template.md`.
4. Yêu cầu chức năng (FR-xx) và phi chức năng (NFR-xx) có số đo cụ thể. Gắn nhãn Module A/B/C.
5. Luật nghiệp vụ thi sát hạch (BR-xx): lấy từ `docs/data/sources.md`; thiếu thì gọi data-curator.
6. qa-engineer kiểm tra: mọi FR có kiểm thử được không? Ghi lại các chỗ mơ hồ.
7. Ghi `docs/srs/SRS.md` theo `docs/templates/srs-template.md` sau khi được duyệt.
8. Nếu là `update`: ghi lịch sử thay đổi trong SRS và báo project-manager đánh giá ảnh hưởng.
