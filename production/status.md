# Trạng thái dự án — hoclaixe

> Cập nhật cuối mỗi phiên làm việc.

**Cập nhật**: 2026-10-04
**Phase hiện tại**: 2 — Yêu cầu (gate discovery PASS có điều kiện 04/10: còn số liệu khảo sát)
**Sprint**: Sprint 0 (03/10–11/10/2026)

## Đã xong
- Áp dụng bản cập nhật v2 (Module D — nhận diện biển báo): agent ml-engineer, 4 skill mới, rule ML, bản nháp yêu cầu.
- `/start`: tên app `hoclaixe`, thông tin team, vai trò.
- Tạo repo private https://github.com/takidang/hoclaixe — nhánh `master`, `dev` (mặc định), `hotfix`.
- `CONTRIBUTING.md` hướng dẫn thành viên 2.
- Hạn LTTTBDD 28/10, phạm vi LTTTBDD = Module A không AI; roadmap lập lại.
- `/discovery`: `docs/srs/vision.md` (đã duyệt), `docs/srs/survey.md`. Phát hiện TT 108/2026/TT-BCA (đề lý thuyết tăng số câu từ 01/3/2027).
- `/gate-check discovery`: PASS có điều kiện (04/10). Đồng bộ bảng module project-context/README với vision.
- Dữ liệu (04/10): trích xuất tự động đủ 600 câu + 293 hình từ PDF chính thức (`tools/extract_questions/`), validator PASS; `docs/data/sources.md`; cấu hình đề `exam-structures.json`. Đã xác minh TT 12/2025 và TT 108/2026 (điểm liệt tính theo hạng; đề 2027 hạ xuống Could).
- Thư mục ảnh tham khảo đối thủ `design/reference/competitors/`.

## Việc tiếp theo
1. Nộp đề tài chuyên ngành (05–11/10). Tên gợi ý: "Xây dựng ứng dụng di động hỗ trợ ôn thi lý thuyết sát hạch lái xe tích hợp trợ lý AI giải thích luật (RAG) và nhận diện biển báo giao thông".
2. `/write-srs` (đang làm; chờ ảnh đối thủ trong `design/reference/competitors/` để chốt hành vi thi thử) — ưu tiên Module A (cho LTTTBDD 28/10); Module B, D viết đủ trong Sprint 2.
3. `/ux-design` Module A, kiến trúc app tối giản, `/setup-flutter` — xong trong Sprint 0.

## Phân công

| Người | Việc đang giao | Hạn |
|---|---|---|
| Tài | Nộp đề tài; SRS + UX Module A, kiến trúc tối giản, `/setup-flutter` | 11/10/2026 |
| Kiệt | Clone repo, đọc `README.md` + `CONTRIBUTING.md` (đã là collaborator `hlo043097-cmd`) | [ĐIỀN] |
| Kiệt | **Ưu tiên 1**: soát `data/question-bank/review.md` (142 câu: 60+ câu điểm liệt, câu 2 cột, mẫu ngẫu nhiên) với PDF gốc, đánh dấu khớp/sai | 10/10 |
| Kiệt | Khảo sát Google Form theo `docs/srs/survey.md`, ≥ 30 phản hồi, tổng hợp số liệu vào vision.md | 10/10 |
| Kiệt | Ưu tiên 2: quy chuẩn biển báo, luật/nghị định giao thông (cho đồ án chuyên ngành) | 08/11 |
| Kiệt | Thu thập yêu cầu format báo cáo, mẫu bìa của giảng viên LTTTBDD → `docs/reports/`; viết báo cáo LTTTBDD từ 19/10 | Mẫu: 11/10 · Báo cáo: 28/10 |

## Blocker / cần bổ sung
- Điều kiện còn mở của gate discovery: số liệu khảo sát điền vào `[CẦN SỐ LIỆU]` trong vision.md (Kiệt, 10/10).
- Chưa có: yêu cầu format báo cáo. Hạn LTTTBDD 28/10 là hạn nội bộ — theo dõi khi trường công bố lịch chính thức.
- Module D: chưa chốt người huấn luyện model (đề xuất: Tài) và phân công chụp ảnh (đề xuất: cả hai).
