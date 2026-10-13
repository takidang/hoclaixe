# Trạng thái dự án — hoclaixe

> Cập nhật cuối mỗi phiên làm việc.

**Cập nhật**: 2026-10-13
**Phase hiện tại**: 3→4 — thiết kế gọn + chuẩn bị (`/create-architecture`, `/setup-flutter`), vào code ngay sau đó
**Sprint**: Sprint 1 (12/10–28/10/2026) — Module A, nộp LTTTBDD 28/10 · đóng băng tính năng 25/10
**Phạm vi (đổi 13/10)**: hoclaixe chỉ còn là đồ án LTTTBDD → Module A giống đối thủ; B/C/D làm sau nếu còn thời gian.

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
- **Danh mục biển báo (cập nhật 06/10)**: 397 mục = 324 biển (Phụ lục B–F) + 43 biển cao tốc IE (Điều 47) + 30 vạch kẻ đường (Phụ lục G); 7 nhóm. Trước đó 324 mã, thêm `summary` = mô tả ngắn nguyên văn QCVN cho từng mã (học cách trình bày của đối thủ). Ban đầu 294 mã + hình trích tự động từ QCVN 41:2024 Phụ lục B–F (`tools/extract_signs/`), validator PASS; danh sách soát `data/sign-catalog/review.md` (129 mục).
- `/write-srs`: `docs/srs/SRS.md` v0.2 (Module A chi tiết, B/D khung), đã qua review agent qa-engineer. Chốt: khóa dọc; danh mục biển báo trích từ QCVN 41:2024 trước 12/10.

- Skill `/tam-nghi` (06/10): nói "tạm nghỉ" → cập nhật status + commit + push.
- Module D chốt (06/10): Gemini vision là phương án chính, TFLite trên máy hạ xuống Could.
- **13/10**: `/create-architecture` — `docs/architecture/architecture.md` + ADR-001…006 (Riverpod, sqflite, JSON đóng gói, không backend, go_router, tắt backup), đã review bảo mật; SRS v0.4.
- **13/10**: đổi phạm vi (chỉ LTTTBDD); sửa lỗi 26 câu thiếu hình (PDF dùng chung hình cho nhiều câu — phát hiện nhờ đối chiếu chéo 08/10, `docs/data/crosscheck-tasks.md`); validator thêm lỗi "câu nói tới hình mà không có hình"; roadmap Sprint 1 theo ngày.

## Việc tiếp theo (phiên sau bắt đầu từ đây)
1. **`/setup-flutter`**: project chạy được trên Android, nạp `questions.json`, `exam-structures.json`, `signs.json` + hình làm assets, test mẫu.
2. Bắt đầu code theo `production/roadmap.md` (15–18/10: chọn hạng, màn chính, học theo chủ đề).

## Phân công

| Người | Việc đang giao | Hạn |
|---|---|---|
| Tài | `/setup-flutter` | 14/10 |
| Tài | Code Module A theo roadmap; giao diện bằng Claude Design song song | 25/10 (đóng băng) |
| Kiệt | Soát danh mục biển báo bằng `data/sign-catalog/review.html` (7 tab; bấm Khớp/Sai + ghi chú, rồi "Xuất kết quả") — ưu tiên biển cấm, nguy hiểm, hiệu lệnh, vạch kẻ đường (có trong đề thi) | 18/10 |
| Kiệt | Lấy yêu cầu format báo cáo, mẫu bìa của giảng viên LTTTBDD → `docs/reports/`; viết báo cáo LTTTBDD từ 19/10 (theo `docs/templates/report-ltttbdd.md`) | Mẫu: 16/10 · Báo cáo: 28/10 |
| Kiệt | Test thử app trên máy Android của mình từ khi có bản chạy được (ghi lỗi vào `production/bugs/`) | từ 19/10 |

## Blocker / cần bổ sung
- Hạn LTTTBDD 28/10 là hạn nội bộ — theo dõi khi trường công bố lịch chính thức.
- Chưa có yêu cầu format báo cáo LTTTBDD từ giảng viên.
- Việc tạm dừng do đổi phạm vi (làm sau nếu còn thời gian): khảo sát người dùng, kho văn bản luật cho RAG, bộ ảnh kiểm tra biển báo.
