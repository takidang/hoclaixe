---
name: web-port
description: "Phase 7 (tùy chọn) — đưa app lên Flutter Web: kiểm tra plugin, responsive, build, deploy."
---

Chủ trì: release-engineer + flutter-developer. Chỉ làm khi `/status` cho thấy Module A (và B) đã ổn định.
1. Liệt kê plugin đang dùng và hỗ trợ web hay không (kiểm tra trang pub.dev). Đề xuất thay thế hoặc conditional import.
2. Local DB trên web: kiểm tra package đã chọn có hỗ trợ web không; nếu không, đề xuất adapter.
3. Layout responsive theo breakpoint trong design-system.md.
4. `flutter build web`, chạy thử, sửa lỗi CORS khi gọi backend.
5. Đề xuất hosting miễn phí và các bước deploy. Ghi ADR cho quyết định chính.
