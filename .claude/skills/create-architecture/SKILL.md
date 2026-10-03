---
name: create-architecture
description: "Phase 3 — thiết kế kiến trúc tổng thể: Flutter app, backend, RAG, database, sơ đồ UML."
---

Chủ trì: technical-director. Hỗ trợ: flutter-developer, backend-developer, ai-engineer, security-reviewer.

1. Đọc SRS, UX spec, rag-design (nếu có).
2. Chốt từng lựa chọn còn `[CHỌN]` trong project-context.md: đưa bảng so sánh 2–3 phương án, khuyến nghị, chờ người dùng chọn.
   Mỗi lựa chọn → một ADR (`/adr`).
3. Viết `docs/architecture/architecture.md` theo `docs/templates/architecture-template.md`:
   - Sơ đồ tổng thể (Mermaid): App ↔ Backend/proxy ↔ Gemini ↔ Vector store ↔ DB;
     thêm các khối "TFLite model (on-device)" và "Gemini vision endpoint".
   - Kiến trúc app: lớp, cấu trúc thư mục feature-first, luồng dữ liệu.
   - ERD (Mermaid `erDiagram`) cho DB local và DB cloud.
   - Sơ đồ lớp/sequence cho 2–3 luồng chính (thi thử, hỏi chatbot) — dùng lại trong báo cáo.
   - Luồng nhận diện biển báo (on-device TFLite → ngưỡng → Gemini vision dự phòng → tra danh mục chuẩn).
   - Chiến lược offline, xử lý lỗi, bảo mật, khả năng build web.
4. security-reviewer review bản nháp. Ghi file sau khi duyệt.
