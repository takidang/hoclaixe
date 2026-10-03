---
name: vision-design
description: "Phase 3 — thiết kế giải pháp nhận diện biển báo: phạm vi lớp, kiến trúc on-device + Gemini dự phòng, ngưỡng, luồng UX, kế hoạch đánh giá."
---

Chủ trì: ml-engineer. Review: technical-director, ux-designer, data-curator, security-reviewer.

1. Đọc README mục 3.4, SRS (Module D), `data/sign-catalog/`, architecture.md.
2. Viết `docs/ml/vision-design.md` theo `docs/templates/vision-design-template.md`.
3. Đưa bảng so sánh 3 phương án (on-device / Gemini vision / kết hợp) về độ chính xác dự kiến, offline, tốc độ, chi phí quota,
   hỗ trợ web, công sức. Khuyến nghị "kết hợp", người dùng quyết → ghi ADR.
4. Xác định ngưỡng độ tin cậy ban đầu và cách hiệu chỉnh trên tập validation.
5. Vẽ sequence diagram (Mermaid) cho: nhận diện được, nhận diện sai, không nhận diện được, rơi về Gemini.
6. Hỏi trước khi ghi.
