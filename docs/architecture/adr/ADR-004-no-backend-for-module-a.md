# ADR-004: Không dùng backend cho Module A
- Ngày: 13/10/2026
- Trạng thái: Chấp nhận

## Bối cảnh
Từ 13/10/2026 hoclaixe chỉ còn là đồ án LTTTBDD: Module A (luyện đề, offline, không AI), hạn 28/10. Không có tài khoản,
đồng bộ hay AI trong phạm vi này.

## Các phương án
| Phương án | Ưu | Nhược |
|---|---|---|
| Không backend (app offline hoàn toàn) | Không tốn thời gian dựng server; không quyền INTERNET; không dữ liệu cá nhân rời máy | Gỡ app mất tiến độ; không đồng bộ nhiều máy |
| Firebase (Auth + Firestore) | Đồng bộ tiến độ, nền cho Module B/D sau này | Thêm cấu hình, quy tắc bảo mật, quyền mạng — không cần cho Module A |

## Quyết định
**Không backend** cho Module A. Mục `Backend` trong `project-context.md` ghi "Không có (Module A)".

## Hệ quả
- Bản release không khai báo quyền nào (kiểm bằng `aapt dump permissions` trong `/release-checklist`).
- Khi làm Module B/D: viết ADR mới cho backend proxy (API key chỉ ở backend) và thêm quyền INTERNET khi đó.
