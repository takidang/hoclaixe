# ADR-001: Quản lý trạng thái bằng Riverpod
- Ngày: 13/10/2026
- Trạng thái: Chấp nhận

## Bối cảnh
Module A có trạng thái dùng chung giữa nhiều màn (hạng đang chọn, tiến độ chủ đề, phiên thi có đồng hồ, danh sách câu sai)
và dữ liệu nạp bất đồng bộ (JSON assets, SQLite). Team 2 người, hạn 28/10/2026 — cần ít code mẫu, dễ test.

## Các phương án
| Phương án | Ưu | Nhược |
|---|---|---|
| Riverpod | Ít boilerplate; provider bất đồng bộ có sẵn trạng thái loading/lỗi; override provider trong test; không phụ thuộc BuildContext | Phải học khái niệm provider/notifier |
| Provider | Đơn giản, quen thuộc | Khó tổ chức khi trạng thái phức tạp (phiên thi + đồng hồ + lưu DB); phụ thuộc cây widget |
| Bloc | Tách sự kiện/trạng thái rất rõ | Nhiều code mẫu nhất, chậm với hạn 28/10 |

## Quyết định
Dùng **Riverpod** cho toàn bộ app; không trộn kiểu quản lý trạng thái khác (`.claude/rules/flutter-code.md`).

## Hệ quả
- Logic nghiệp vụ (sinh đề, chấm điểm) đặt trong lớp domain thuần Dart, provider chỉ điều phối → unit test không cần Flutter.
- Phiên bản package chốt trong `/setup-flutter`.
