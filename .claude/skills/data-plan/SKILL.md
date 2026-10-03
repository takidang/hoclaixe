---
name: data-plan
description: "Phase 3 — xác định nguồn dữ liệu chính thức (bộ câu hỏi, biển báo, luật), định dạng, script kiểm tra dữ liệu."
---

Chủ trì: data-curator.

1. Dùng WebSearch xác định bộ câu hỏi sát hạch đang áp dụng và các văn bản luật/nghị định giao thông đường bộ còn hiệu lực.
   Kiểm tra văn bản đã bị thay thế/sửa đổi chưa.
2. Ghi `docs/data/sources.md`: tên, số hiệu, cơ quan ban hành, ngày hiệu lực, link, ngày truy cập, ghi chú bản quyền.
3. Lập bảng cấu trúc đề thi theo hạng bằng (số câu, thời gian, điểm đạt, số câu điểm liệt) — chỉ từ nguồn chính thức;
   chưa xác minh được thì ghi `[CHƯA XÁC MINH]`.
4. Đề xuất schema JSON cho câu hỏi, chủ đề, biển báo, điều luật (ví dụ trong `docs/templates/data-schema.md`).
5. Lập danh mục biển báo `data/sign-catalog/signs.json` theo quy chuẩn kỹ thuật quốc gia về báo hiệu đường bộ đang hiệu lực
   (xác minh số hiệu và ngày hiệu lực bằng WebSearch): mã, tên, nhóm, tác dụng, ảnh chuẩn, id câu hỏi liên quan.
6. Đề xuất script kiểm tra dữ liệu (Dart hoặc Python) trong `tools/validate_data`. Hỏi trước khi tạo.
7. Không tự soạn câu hỏi hay nội dung luật. Việc nhập liệu thật do người dùng làm hoặc có script từ nguồn chính thức.
