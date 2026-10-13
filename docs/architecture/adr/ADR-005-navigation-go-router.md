# ADR-005: Điều hướng bằng go_router
- Ngày: 13/10/2026
- Trạng thái: Chấp nhận

## Bối cảnh
App có ~12 màn (miễn trừ, chọn hạng, màn chính, chủ đề, học, thi thử, bộ đề, kết quả, xem lại, biển báo, chi tiết biển,
giới thiệu). Cần chặn điều hướng theo điều kiện (chưa đồng ý miễn trừ → màn miễn trừ; có phiên thi dở → hỏi tiếp tục)
và xử lý nút quay lại trong màn thi (bảng chọn Nộp / Lưu tạm / Không lưu / Tiếp tục).

## Các phương án
| Phương án | Ưu | Nhược |
|---|---|---|
| go_router | Package chính thức của nhóm Flutter; khai báo route tập trung; `redirect` cho điều kiện; hỗ trợ web URL sau này | Thêm một phụ thuộc |
| Navigator 1.0 (push/pop) | Có sẵn, đơn giản | Điều kiện chuyển màn rải rác; khó làm web |

## Quyết định
Dùng **go_router**, khai báo trong `lib/core/router.dart`; `redirect` đọc trạng thái miễn trừ/hạng từ Riverpod.

## Hệ quả
Màn thi dùng `PopScope` để chặn quay lại và hiện bảng chọn thoát bài.
