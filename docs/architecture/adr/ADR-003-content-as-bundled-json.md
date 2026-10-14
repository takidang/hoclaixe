# ADR-003: Nội dung (câu hỏi, cấu trúc đề, biển báo) đóng gói dạng JSON chỉ đọc
- Ngày: 13/10/2026
- Trạng thái: Chấp nhận

## Bối cảnh
600 câu hỏi, cấu trúc đề và 397 biển/vạch được trích xuất tự động từ văn bản chính thức và kiểm bằng validator trong `data/`.
App chỉ đọc, không sửa nội dung (BR-07). Tổng ~1.000 mục, < 2 MB JSON.

## Các phương án
| Phương án | Ưu | Nhược |
|---|---|---|
| JSON trong assets, nạp vào bộ nhớ lúc mở app | Đơn giản; dữ liệu trong app giống hệt `data/` đã kiểm; truy vấn tức thì | Nạp lúc khởi động (~vài trăm ms, làm trong isolate) |
| Nhập JSON vào SQLite lần đầu chạy | Truy vấn SQL được | Phải đồng bộ hai nơi khi cập nhật dữ liệu; migration phức tạp hơn |
| Gọi API tải nội dung | Cập nhật không cần phát hành app | Cần backend và mạng — trái phạm vi offline |

## Quyết định
Đóng gói JSON + hình vào `src/app/assets/` bằng `tools/sync_assets.py`, kèm `content_version.json` (phiên bản + SHA-256).
Nạp một lần vào bộ nhớ (`compute`), kiểm cấu trúc, lỗi → màn báo lỗi rõ ràng.

## Hệ quả
- Validator chạy trên cả `data/` và `src/app/assets/`; unit test so hash để bắt việc quên đồng bộ.
- Cập nhật bộ đề = phát hành bản app mới (chấp nhận với đồ án).
