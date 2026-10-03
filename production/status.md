# Trạng thái dự án — hoclaixe

> Cập nhật cuối mỗi phiên làm việc.

**Cập nhật**: 2026-10-03
**Phase hiện tại**: 1 — Discovery (vision đã duyệt, chờ `/gate-check discovery`)
**Sprint**: Sprint 0 (03/10–11/10/2026)

## Đã xong
- Áp dụng bản cập nhật v2 (Module D — nhận diện biển báo): agent ml-engineer, 4 skill mới, rule ML, bản nháp yêu cầu.
- `/start`: tên app `hoclaixe`, thông tin team, vai trò.
- Tạo repo private https://github.com/takidang/hoclaixe — nhánh `master`, `dev` (mặc định), `hotfix`.
- `CONTRIBUTING.md` hướng dẫn thành viên 2.
- Hạn LTTTBDD 28/10, phạm vi LTTTBDD = Module A không AI; roadmap lập lại.
- `/discovery`: `docs/srs/vision.md` (đã duyệt), `docs/srs/survey.md`. Phát hiện TT 108/2026/TT-BCA (đề lý thuyết tăng số câu từ 01/3/2027).

## Việc tiếp theo
1. `/gate-check discovery` (chốt đề tài trước 11/10/2026).
2. `/write-srs` — ưu tiên Module A (cho LTTTBDD 28/10); Module B, D viết đủ trong Sprint 2.
3. `/ux-design` Module A, kiến trúc app tối giản, `/setup-flutter` — xong trong Sprint 0.

## Phân công

| Người | Việc đang giao | Hạn |
|---|---|---|
| Tài | `/discovery`, SRS + UX Module A, `/setup-flutter` | 11/10/2026 |
| Kiệt | Clone repo, đọc `README.md` + `CONTRIBUTING.md` (đã là collaborator `hlo043097-cmd`) | [ĐIỀN] |
| Kiệt | **Ưu tiên 1**: tìm nguồn chính thức bộ câu hỏi sát hạch hiện hành (+ cấu trúc đề theo hạng, câu điểm liệt) → `docs/data/sources.md`, rồi nhập vào `data/question-bank/` | Nguồn: 08/10 · Nhập xong: 15/10 |
| Kiệt | Khảo sát Google Form theo `docs/srs/survey.md`, ≥ 30 phản hồi, tổng hợp số liệu vào vision.md | 10/10 |
| Kiệt | Đọc nguyên văn TT 108/2026/TT-BCA: chuyển tiếp, cấu trúc đề từ 01/3/2027, bộ câu hỏi/dạng câu mới, bỏ sát hạch mô phỏng → `docs/data/sources.md` | 08/10 |
| Kiệt | Ưu tiên 2: quy chuẩn biển báo, luật/nghị định giao thông (cho đồ án chuyên ngành) | 08/11 |
| Kiệt | Thu thập yêu cầu format báo cáo, mẫu bìa của giảng viên LTTTBDD → `docs/reports/`; viết báo cáo LTTTBDD từ 19/10 | Mẫu: 11/10 · Báo cáo: 28/10 |

## Blocker / cần bổ sung
- Chưa có: yêu cầu format báo cáo. Hạn LTTTBDD 28/10 là hạn nội bộ — theo dõi khi trường công bố lịch chính thức.
- Module D: chưa chốt người huấn luyện model (đề xuất: Tài) và phân công chụp ảnh (đề xuất: cả hai).
