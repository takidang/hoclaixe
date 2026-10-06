# Trạng thái dự án — hoclaixe

> Cập nhật cuối mỗi phiên làm việc.

**Cập nhật**: 2026-10-04 (cuối phiên 2)
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
- Ảnh tham khảo đối thủ: 21 ảnh / 2 app trong `design/reference/competitors/`; SRS v0.3 đã đối chiếu.
- **Công cụ soát không dùng AI (04/10)**: `tools/review_ui/make_question_review.py` → trang HTML so PDF gốc với dữ liệu app; dò lại gạch chân bằng xử lý ảnh, khớp 600/600 đáp án. (Thử soát bằng 2 agent data-curator bị dừng do hết giới hạn phiên — quá tốn token khi xem hàng trăm trang.)
- **Soát bộ câu hỏi (06/10, Kiệt)**: phát hiện 2 lỗi — câu 180, 485 bị dính dòng 2 của tiêu đề chương; đã sửa script + thêm kiểm tra tự động (cụm chữ IN HOA). Máy dò lại đáp án khớp 600/600.
- **Danh mục biển báo (cập nhật 06/10)**: 324 mã, thêm `summary` = mô tả ngắn nguyên văn QCVN cho từng mã (học cách trình bày của đối thủ). Ban đầu 294 mã + hình trích tự động từ QCVN 41:2024 Phụ lục B–F (`tools/extract_signs/`), validator PASS; danh sách soát `data/sign-catalog/review.md` (129 mục).
- `/write-srs`: `docs/srs/SRS.md` v0.2 (Module A chi tiết, B/D khung), đã qua review agent qa-engineer. Chốt: khóa dọc; danh mục biển báo trích từ QCVN 41:2024 trước 12/10.

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
| Kiệt | Soát danh mục biển báo bằng trang `data/sign-catalog/review.html` (tạo bằng `python tools/review_ui/make_sign_review.py`, 1 file gửi riêng được): 5 tab theo nhóm biển, mỗi biển có đề mục + hình trong PDF cạnh hình/tên/ý nghĩa trong app. Bấm **Khớp** hoặc **Sai** + ghi chú cho từng biển (bộ đếm "đã xem" theo nhóm), xong bấm "Xuất kết quả". Tối thiểu: lọc "Trong review.md" (129 biển) | 12/10 |
| Kiệt | **Ưu tiên 1**: soát bộ câu hỏi bằng trang `data/question-bank/review.html` (tạo bằng `python tools/review_ui/make_question_review.py`): mỗi câu có ảnh PDF gốc cạnh dữ liệu app — chỉ so **nội dung, đáp án, hình**, bấm "Sai" nếu lệch, rồi "Xuất kết quả" gửi file JSON. Đáp án đúng đã được máy dò lại bằng cách thứ hai, khớp 600/600. Ưu tiên lọc "Trong review.md" (142 câu, ~10 phút); dư thời gian soát hết 600 câu (~45 phút) | 10/10 |
| Kiệt | Khảo sát Google Form theo `docs/srs/survey.md`, ≥ 30 phản hồi, tổng hợp số liệu vào vision.md | 10/10 |
| Kiệt | Thu thập yêu cầu format báo cáo, mẫu bìa của giảng viên LTTTBDD → `docs/reports/`; viết báo cáo LTTTBDD từ 19/10 | Mẫu: 11/10 · Báo cáo: 28/10 |
| Kiệt | Ưu tiên 2 (không gấp, cho RAG — đồ án chuyên ngành): tải bản **có chữ** (.doc/.docx/PDF chữ, ưu tiên vbpl.vn, chinhphu.vn) vào `data/law-corpus/raw/` và ghi `docs/data/sources.md`: Luật TTATGTĐB 36/2024/QH15; Luật 118/2025/QH15 (sửa đổi); QCVN 41:2024/BGTVT; NĐ 168/2024/NĐ-CP; **NĐ 238/2026/NĐ-CP** (sửa NĐ 168, hiệu lực 15/8/2026); NĐ 151/2024/NĐ-CP; Luật Đường bộ 35/2024/QH15 | 08/11 |

## Blocker / cần bổ sung
- Điều kiện còn mở của gate discovery: số liệu khảo sát điền vào `[CẦN SỐ LIỆU]` trong vision.md (Kiệt, 10/10).
- Hỏi giảng viên: yêu cầu format báo cáo; (tùy chọn) xác nhận việc dùng bộ câu hỏi công khai trong đồ án.
- Hạn LTTTBDD 28/10 là hạn nội bộ — theo dõi khi trường công bố lịch chính thức.
- Module D: chưa chốt người huấn luyện model (đề xuất: Tài) và phân công chụp ảnh (đề xuất: cả hai).
