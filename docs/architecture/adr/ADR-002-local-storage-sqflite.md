# ADR-002: Lưu dữ liệu người học bằng SQLite (sqflite)
- Ngày: 13/10/2026
- Trạng thái: Chấp nhận

## Bối cảnh
Cần lưu tiến độ học, câu sai, lịch sử và **phiên thi đang làm** sao cho đáp án không bao giờ mất/đổi (FR-A24, NFR-02 —
đây là lỗi bị phàn nàn ở app đối thủ), nộp bài đúng một lần (FR-A26), truy vấn thống kê theo chủ đề.

## Các phương án
| Phương án | Ưu | Nhược |
|---|---|---|
| sqflite | SQLite ổn định; transaction cho lưu đáp án và nộp bài; SQL rõ ràng, có ERD cho báo cáo; không sinh code | Viết SQL tay, tự lo migration |
| drift | SQLite có kiểu chặt, truy vấn an toàn | Cần build_runner sinh code, cài đặt và sửa lỗi lâu hơn |
| Hive / Isar | NoSQL nhanh, dễ dùng | Khó truy vấn thống kê; không có ERD; Isar không còn được duy trì tích cực |

## Quyết định
Dùng **sqflite**. 6 bảng: `app_setting`, `question_state`, `answer_log`, `topic_position`, `exam_session`, `exam_answer`
(xem `docs/architecture/architecture.md` §4). Bật `foreign_keys`, WAL; migration theo `user_version`, từng bước trong
transaction, không xóa dữ liệu khi hạ phiên bản.

## Hệ quả
- Test lớp data trên máy dev bằng `sqflite_common_ffi`.
- Bản web sau này (Module C) cần thay bằng bản web của SQLite hoặc drift — lớp data đặt sau interface nên không ảnh hưởng UI.

## Cập nhật 14/10/2026 — chạy được trên web
- Lý do: thành viên team không có emulator Android, chạy `flutter run` trên Chrome thì không mở được DB.
- Dùng `sqflite_common_ffi_web` (sqlite3.wasm trong shared worker, dữ liệu trong IndexedDB). Chọn theo nền tảng bằng
  import có điều kiện `lib/core/db/platform_database.dart`; không đổi schema, không đổi repository hay UI. Web không bật WAL.
- `web/sqlite3.wasm` và `web/sqflite_sw.js` (tạo bằng `dart run sqflite_common_ffi_web:setup`) được commit để clone về chạy ngay;
  khi nâng `sqflite_common_ffi_web` chạy lại lệnh với `--force`.
- Đã kiểm: build web + mở DB trong Edge headless, tạo đủ 6 bảng, dữ liệu còn sau khi tải lại trang.
- Giới hạn: tiến độ gắn với origin (cổng) của trình duyệt → chạy dev luôn dùng `--web-port 8080`. Bản nộp đồ án vẫn là Android;
  giao diện web chưa tối ưu màn hình rộng (Module C).
