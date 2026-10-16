# Học lái xe (hoclaixe)

Ứng dụng Flutter ôn thi lý thuyết sát hạch giấy phép lái xe hạng **A1, A, B** — chạy **offline**, dùng bộ 600 câu hỏi
chính thức của Cục Cảnh sát giao thông (áp dụng từ 01/6/2025) và cấu trúc đề theo Công văn 2262/CSGT-P5.

Đồ án môn **Lập trình thiết bị di động** — Đặng Lê Tấn Tài (2380601937), Nguyễn Đỗ Tuấn Kiệt (2380601147).

## Chức năng
- Đọc tuyên bố miễn trừ, chọn hạng bằng (mô tả loại xe theo Luật 36/2024/QH15 Điều 57), đổi hạng bất kỳ lúc nào
- Màn chính: tiến độ ôn tập, số câu sai, câu điểm liệt, tiếp tục bài thi dở
- Học theo chủ đề (tất cả câu hỏi, câu điểm liệt, 6 chương): chọn đáp án → hiện đúng/sai ngay, lưới số câu,
  nhớ câu đang dở, làm lại chủ đề
- Ôn câu sai (câu ra khỏi danh sách khi trả lời đúng 2 lần liên tiếp) và ôn câu điểm liệt theo hạng
- Phóng to hình (chụm 2 ngón tới 4 lần, chạm đúp để trở về)
- Đang làm: thi thử bấm giờ, kết quả và xem lại bài, 20 đề cố định, danh mục biển báo (QCVN 41:2024)

## Chạy app
Yêu cầu: Flutter 3.47+ (Dart 3.13). Kiểm tra bằng `flutter doctor`.

```bash
flutter pub get
flutter run                                  # Android: emulator hoặc điện thoại bật Gỡ lỗi USB
flutter run -d chrome --web-port 8080        # web (xem nhanh); giữ cổng 8080 để không mất tiến độ
```
**Android Studio**: File → Open → chọn thư mục này → chờ "Pub get" → chọn thiết bị → nút ▶.

Kiểm tra code:
```bash
flutter analyze   # No issues found!
flutter test      # unit test + widget test (dữ liệu thật, SQLite thật trong bộ nhớ)
```

## Công nghệ
| | |
|---|---|
| Giao diện | Flutter, Material 3 |
| State management | Riverpod 3 |
| Lưu tiến độ | SQLite — `sqflite` trên Android, `sqflite_common_ffi_web` (sqlite3.wasm, IndexedDB) trên web |
| Điều hướng | go_router (điều hướng theo trạng thái: miễn trừ → chọn hạng → màn chính) |
| Nội dung | JSON chỉ đọc đóng gói trong `assets/` (câu hỏi, cấu trúc đề, biển báo) kèm mã băm kiểm tra |

Không có backend, không thu thập dữ liệu người dùng; tiến độ chỉ lưu trên máy (tắt sao lưu Android).

## Cấu trúc
```
lib/
  main.dart                  khởi động, khóa màn hình dọc
  core/                      dùng chung: nội dung, SQLite, router, theme, chuỗi hiển thị, đồng hồ
  features/<tính năng>/      chia theo tính năng (onboarding, home, study, exam, about)
    domain/                  logic thuần Dart: sinh đề, chấm điểm, chủ đề, thống kê
    data/                    repository SQLite + provider
    presentation/            màn hình và widget
  shared/widgets/            QuestionView (học / thi / xem lại), phóng to hình
assets/                      dữ liệu và hình đã trích từ văn bản chính thức
test/                        cấu trúc giống lib/
web/                         bản web + sqlite3.wasm
```

## Nguồn dữ liệu
- Bộ 600 câu hỏi dùng cho sát hạch lái xe cơ giới đường bộ — Cục CSGT, Bộ Công an
- Công văn 2262/CSGT-P5 (07/5/2025) — cấu trúc đề, câu điểm liệt theo hạng
- Thông tư 12/2025/TT-BCA — thời gian làm bài, điểm đạt
- QCVN 41:2024/BGTVT — báo hiệu đường bộ
- Luật Trật tự, an toàn giao thông đường bộ số 36/2024/QH15 — Điều 57

Dữ liệu được trích tự động từ các văn bản trên bằng công cụ Python và soát bằng tay; công cụ, tài liệu yêu cầu
và kiến trúc nằm ở repo làm việc của nhóm. Ứng dụng là sản phẩm học tập độc lập, không đại diện cơ quan nhà nước.
