# Trạng thái dự án — hoclaixe

> Cập nhật cuối mỗi phiên làm việc.

**Cập nhật**: 2026-10-03
**Phase hiện tại**: 0 — Khởi động (xong) → sắp vào Phase 1 — Discovery
**Sprint**: Sprint 0 (03/10–11/10/2026)

## Đã xong
- Áp dụng bản cập nhật v2 (Module D — nhận diện biển báo): agent ml-engineer, 4 skill mới, rule ML, bản nháp yêu cầu.
- `/start`: tên app `hoclaixe`, thông tin team, vai trò.
- Tạo repo private https://github.com/takidang/hoclaixe — nhánh `master`, `dev` (mặc định), `hotfix`.
- `CONTRIBUTING.md` hướng dẫn thành viên 2.

## Việc tiếp theo
1. `/discovery` → `/gate-check discovery` (chốt đề tài trước 11/10/2026).
2. `/write-srs` — ưu tiên Module A (cho LTTTBDD 28/10); Module B, D viết đủ trong Sprint 2.
3. `/ux-design` Module A, kiến trúc app tối giản, `/setup-flutter` — xong trong Sprint 0.

## Phân công

| Người | Việc đang giao | Hạn |
|---|---|---|
| Tài | `/discovery`, SRS + UX Module A, `/setup-flutter` | 11/10/2026 |
| Kiệt | Clone repo, đọc `README.md` + `CONTRIBUTING.md` (đã là collaborator `hlo043097-cmd`) | [ĐIỀN] |
| Kiệt | **Ưu tiên 1**: tìm nguồn chính thức bộ câu hỏi sát hạch hiện hành (+ cấu trúc đề theo hạng, câu điểm liệt) → `docs/data/sources.md`, rồi nhập vào `data/question-bank/` | Nguồn: 08/10 · Nhập xong: 15/10 |
| Kiệt | Ưu tiên 2: quy chuẩn biển báo, luật/nghị định giao thông (cho đồ án chuyên ngành) | 08/11 |
| Kiệt | Thu thập yêu cầu format báo cáo, mẫu bìa của giảng viên LTTTBDD → `docs/reports/`; viết báo cáo LTTTBDD từ 19/10 | Mẫu: 11/10 · Báo cáo: 28/10 |

## Blocker / cần bổ sung
- Chưa có: yêu cầu format báo cáo. Hạn LTTTBDD 28/10 là hạn nội bộ — theo dõi khi trường công bố lịch chính thức.
- Module D: chưa chốt người huấn luyện model (đề xuất: Tài) và phân công chụp ảnh (đề xuất: cả hai).
