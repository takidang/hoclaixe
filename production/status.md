# Trạng thái dự án — hoclaixe

> Cập nhật cuối mỗi phiên làm việc.

**Cập nhật**: 2026-10-04 (cuối phiên)
**Phase hiện tại**: 2 — Yêu cầu (gate discovery PASS có điều kiện 04/10: còn số liệu khảo sát)
**Sprint**: Sprint 0 (03/10–11/10/2026) — còn 7 ngày
**Mốc gần nhất**: nộp đề tài chuyên ngành 05–11/10 · hạn LTTTBDD 28/10

## Đã xong
- Áp dụng bản cập nhật v2 (Module D — nhận diện biển báo): agent ml-engineer, 4 skill mới, rule ML, bản nháp yêu cầu.
- `/start`: tên app `hoclaixe`, thông tin team, vai trò.
- Tạo repo private https://github.com/takidang/hoclaixe — nhánh `master`, `dev` (mặc định), `hotfix`; Kiệt là collaborator.
- `CONTRIBUTING.md` hướng dẫn thành viên 2.
- Hạn LTTTBDD 28/10, phạm vi LTTTBDD = Module A không AI; roadmap lập lại.
- `/discovery`: `docs/srs/vision.md` (đã duyệt), `docs/srs/survey.md`.
- `/gate-check discovery`: PASS có điều kiện (04/10).
- **Dữ liệu câu hỏi (04/10)**: trích xuất tự động đủ 600 câu + 293 hình từ PDF chính thức (`tools/extract_questions/`),
  validator PASS (`tools/validate_data/validate_questions.py`); điểm liệt theo hạng (`criticalFor`); cấu hình đề
  `data/question-bank/exam-structures.json` (A1, A, B hiện hành; 2027 để `incomplete`).
- **Nguồn đã xác minh** (`docs/data/sources.md`): CV 2262/CSGT-P5, bộ 600 câu, TT 12/2025 (đến 28/02/2027), TT 108/2026 (lý thuyết mới từ 01/3/2027, chưa đủ để tạo đề → Could).
- Thư mục ảnh tham khảo đối thủ `design/reference/competitors/` (chưa có ảnh).
- `/write-srs` đã bắt đầu: đã đề xuất actor + 13 UC Module A + 6 UC khung B/D (chưa ghi file).

## Việc tiếp theo (phiên sau bắt đầu từ đây)
1. **Nộp đề tài chuyên ngành** (05–11/10). Tên gợi ý: "Xây dựng ứng dụng di động hỗ trợ ôn thi lý thuyết sát hạch lái xe
   tích hợp trợ lý AI giải thích luật (RAG) và nhận diện biển báo giao thông".
2. **Tiếp tục `/write-srs`** — nguyên tắc người dùng đã chốt: *hành vi giống app đối thủ*.
   - Nếu đã có ảnh trong `design/reference/competitors/` → phân tích ảnh để chốt: điều hướng khi thi (tới/lui, lưới câu,
     đánh dấu), hết giờ tự nộp, khi nào bỏ câu khỏi "câu sai", có bộ đề cố định không, màn kết quả/xem lại.
   - Nếu chưa có ảnh → viết theo hành vi đối thủ đã biết (đề ngẫu nhiên bấm giờ, chuyển câu tự do, ôn câu sai, câu hay sai) và ghi giả định.
   - BR lấy từ `docs/data/sources.md` §3 (đã xác minh); điểm liệt theo hạng.
   - Ghi `docs/srs/SRS.md` sau khi duyệt.
3. `/ux-design` Module A (đầu vào cho Claude Design) → `/create-architecture` tối giản (chọn state management + local DB;
   chưa cần backend) → `/setup-flutter`. Mục tiêu xong trước 11/10 để 12/10 vào code.

## Phân công

| Người | Việc đang giao | Hạn |
|---|---|---|
| Tài | Nộp đề tài; chụp ảnh màn hình app đối thủ vào `design/reference/competitors/` (đặt tên theo README trong thư mục) | 06/10 |
| Tài | SRS + UX Module A, kiến trúc tối giản, `/setup-flutter` | 11/10 |
| Kiệt | Clone repo, đọc `README.md` + `CONTRIBUTING.md` | 06/10 |
| Kiệt | **Ưu tiên 1**: soát `data/question-bank/review.md` (142 câu: câu điểm liệt, câu đáp án 2 cột, mẫu ngẫu nhiên) với PDF gốc, đánh dấu khớp/sai | 10/10 |
| Kiệt | Khảo sát Google Form theo `docs/srs/survey.md`, ≥ 30 phản hồi, tổng hợp số liệu vào vision.md | 10/10 |
| Kiệt | Thu thập yêu cầu format báo cáo, mẫu bìa của giảng viên LTTTBDD → `docs/reports/`; viết báo cáo LTTTBDD từ 19/10 | Mẫu: 11/10 · Báo cáo: 28/10 |
| Kiệt | Ưu tiên 2 (không gấp, cho RAG — đồ án chuyên ngành): tải bản **có chữ** (.doc/.docx/PDF chữ, ưu tiên vbpl.vn, chinhphu.vn) vào `data/law-corpus/raw/` và ghi `docs/data/sources.md`: Luật TTATGTĐB 36/2024/QH15; Luật 118/2025/QH15 (sửa đổi); QCVN 41:2024/BGTVT; NĐ 168/2024/NĐ-CP; **NĐ 238/2026/NĐ-CP** (sửa NĐ 168, hiệu lực 15/8/2026); NĐ 151/2024/NĐ-CP; Luật Đường bộ 35/2024/QH15 | 08/11 |

## Blocker / cần bổ sung
- Điều kiện còn mở của gate discovery: số liệu khảo sát điền vào `[CẦN SỐ LIỆU]` trong vision.md (Kiệt, 10/10).
- Hỏi giảng viên: yêu cầu format báo cáo; (tùy chọn) xác nhận việc dùng bộ câu hỏi công khai trong đồ án.
- Hạn LTTTBDD 28/10 là hạn nội bộ — theo dõi khi trường công bố lịch chính thức.
- Module D: chưa chốt người huấn luyện model (đề xuất: Tài) và phân công chụp ảnh (đề xuất: cả hai).
