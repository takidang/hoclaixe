# ADR-006: Tắt sao lưu tự động của Android
- Ngày: 13/10/2026
- Trạng thái: Chấp nhận (theo review của security-reviewer)

## Bối cảnh
Android mặc định `allowBackup=true`: dữ liệu app (SQLite tiến độ, phiên thi) được Auto Backup lên Google Drive và khôi
phục trên máy khác. Điều này trái với cam kết "không gửi gì ra ngoài" (NFR-08) và có thể khôi phục DB lệch phiên bản
dữ liệu hoặc một phiên thi dở cũ.

## Các phương án
| Phương án | Ưu | Nhược |
|---|---|---|
| Tắt backup (`allowBackup="false"` + `dataExtractionRules` loại trừ hết) | Khớp NFR-08; không có dữ liệu cũ bất ngờ quay lại | Đổi máy / gỡ app là mất tiến độ |
| Giữ backup + kiểm tra DB sau khôi phục | Giữ được tiến độ khi đổi máy | Dữ liệu rời máy; thêm code kiểm tra hợp lệ sau restore |

## Quyết định
**Tắt backup.** Màn Giới thiệu ghi "Tiến độ chỉ lưu trên máy này".

## Hệ quả
Xuất/nhập tiến độ bằng file JSON (ý tưởng từ repo tham khảo) ghi vào `production/ideas.md` — làm sau 28/10 nếu cần.
