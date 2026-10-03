---
paths:
  - "src/app/lib/**"
---

# Quy tắc code Flutter

- Cấu trúc feature-first: `lib/features/<feature>/{presentation,domain,data}/`, phần dùng chung ở `lib/core/`.
- Lớp `presentation` không gọi trực tiếp DB/HTTP; đi qua repository/use case.
- Lớp `domain` thuần Dart: không import Flutter, không `dart:io` → test dễ, chạy được trên web.
- State management theo ADR đã chốt; không trộn nhiều kiểu.
- Widget > ~150 dòng → tách widget con. Ưu tiên `const` constructor.
- Không hardcode màu/cỡ chữ: lấy từ `Theme.of(context)` / design system.
- Chuỗi hiển thị gom về một chỗ (ví dụ `lib/core/strings.dart` hoặc l10n).
- Mọi `Future` gọi mạng có timeout và xử lý lỗi; UI có trạng thái loading / lỗi / rỗng / offline.
- Không có API key hay URL bí mật trong code. Cấu hình qua `--dart-define`.
- Không dùng `print` ở code thật; dùng logger, không log dữ liệu cá nhân.
- Đặt tên: file `snake_case.dart`, class `PascalCase`, biến/hàm `camelCase`.
