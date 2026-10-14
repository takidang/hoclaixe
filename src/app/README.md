# hoclaixe — app Flutter (Module A)

Ôn thi lý thuyết sát hạch lái xe A1, A, B — offline, không AI. Kiến trúc: `docs/architecture/architecture.md`.

## Yêu cầu
- Flutter 3.47+ (Dart 3.13), Android SDK 36 — kiểm bằng `flutter doctor` (Chrome/Visual Studio báo thiếu cũng không sao).
- Android Studio (hoặc VS Code) để chạy emulator.

## Chạy lần đầu
```bash
cd src/app
flutter pub get
flutter run            # chọn máy Android đang cắm USB hoặc emulator
flutter run -d chrome --web-port 8080   # bản web (xem nhanh); giữ cổng 8080 để không mất tiến độ
```
Máy mới: chạy `tools/check-setup.ps1` (xem `CONTRIBUTING.md` mục 2a).
**Android Studio**: File → Open → chọn thư mục `src/app` → chờ "Pub get" → chọn thiết bị trên thanh công cụ → nút ▶.
**Máy thật**: bật Tùy chọn nhà phát triển + Gỡ lỗi USB, cắm cáp, chấp nhận khóa RSA trên điện thoại; `flutter devices` phải thấy máy.

## Khi dữ liệu trong `data/` thay đổi
```bash
python tools/validate_data/validate_questions.py
python tools/validate_data/validate_signs.py
python tools/sync_assets.py        # chép vào src/app/assets + content_version.json
cd src/app && flutter test         # test hash bắt lỗi quên sync
```

## Kiểm tra trước khi đẩy code
```bash
flutter analyze   # phải "No issues found!"
flutter test      # phải "All tests passed!"
```

## Cấu trúc
```
lib/
  main.dart                 ProviderScope + MaterialApp.router (khóa dọc)
  core/content/             model nội dung (Dart thuần) + nạp JSON từ assets
  core/db/app_database.dart SQLite: 6 bảng, migration theo version
  core/providers.dart       contentProvider, databaseProvider (Riverpod)
  core/router.dart          go_router
  core/theme/, strings.dart giao diện + mọi chuỗi hiển thị
  features/<tính năng>/     presentation / application / domain / data
assets/                     do tools/sync_assets.py sinh — không sửa tay
test/                       unit + widget test
```
