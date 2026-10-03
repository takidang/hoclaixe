---
name: setup-flutter
description: "Phase 4 — tạo project Flutter theo kiến trúc đã chốt, cài package, lint, cấu trúc thư mục, test mẫu, .gitignore an toàn."
---

Chủ trì: flutter-developer. Review: technical-director, release-engineer.

1. Kiểm tra môi trường: `flutter --version`, `flutter doctor`. Báo vấn đề nếu có (Android SDK, license…).
2. Đọc architecture.md và ADR. Đề xuất lệnh `flutter create` (org, tên, platforms android,web) — chờ duyệt.
   Mặc định tạo trong `src/app/` (hoặc nơi người dùng chọn); cập nhật đường dẫn trong `.claude/rules/*.md` nếu khác.
3. Thêm package đã chốt trong ADR; bật lint chặt (`flutter_lints` hoặc `very_good_analysis` nếu đã chọn).
4. Tạo cấu trúc thư mục feature-first, router, theme từ design-system.md, cấu hình `--dart-define` cho môi trường.
5. Bổ sung `.gitignore`: `.env*`, `*.jks`, `key.properties`, `google-services.json` (nếu team quyết không commit), service account.
6. Một unit test và một widget test mẫu. Chạy `flutter analyze` và `flutter test` — phải sạch.
7. Hướng dẫn mở project trong Android Studio và chạy trên emulator/máy thật.
