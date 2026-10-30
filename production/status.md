# Trạng thái dự án — hoclaixe

> Cập nhật cuối mỗi phiên làm việc.

**Cập nhật**: 2026-10-30
**Phase hiện tại**: 5 — Phát triển, cuối Sprint 1. ST-01…ST-16 Done (Module A đủ); giao diện v2, ảnh xe, chuyển động, tự chuyển câu đã merge vào `dev` (30/10); 176 test đạt, analyze sạch
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
- **Danh mục biển báo (cập nhật 06/10; sửa 14/10 — xem dưới)**: 397 mục = 324 biển (Phụ lục B–F) + 43 biển cao tốc IE (Điều 47) + 30 vạch kẻ đường (Phụ lục G); 7 nhóm. Trước đó 324 mã, thêm `summary` = mô tả ngắn nguyên văn QCVN cho từng mã (học cách trình bày của đối thủ). Ban đầu 294 mã + hình trích tự động từ QCVN 41:2024 Phụ lục B–F (`tools/extract_signs/`), validator PASS; danh sách soát `data/sign-catalog/review.md` (129 mục).
- `/write-srs`: `docs/srs/SRS.md` v0.2 (Module A chi tiết, B/D khung), đã qua review agent qa-engineer. Chốt: khóa dọc; danh mục biển báo trích từ QCVN 41:2024 trước 12/10.

- Skill `/tam-nghi` (06/10): nói "tạm nghỉ" → cập nhật status + commit + push.
- Module D chốt (06/10): Gemini vision là phương án chính, TFLite trên máy hạ xuống Could.
- **13/10**: `/create-stories` — `production/backlog.md` + 16 story ST-01…ST-16 (Must 47 pt, Should 6 pt). **ST-01 Done**: sinh đề / chấm điểm / chọn cấu trúc (thuần Dart, 3.000 đề test trên dữ liệu thật, 37/37 test). Nhật ký cho báo cáo: `docs/reports/dev-log.md`.
- **13/10**: `/setup-flutter` — project `src/app/` (com.takidang.hoclaixe, Android), Riverpod 3.4 / sqflite 2.4 / go_router 18; `tools/sync_assets.py` (12,4 MB assets + content_version.json); DB 6 bảng; tắt backup, khóa dọc; `flutter analyze` sạch, 7/7 test, build APK debug OK. Hướng dẫn chạy: `src/app/README.md`.
- **13/10**: `/create-architecture` — `docs/architecture/architecture.md` + ADR-001…006 (Riverpod, sqflite, JSON đóng gói, không backend, go_router, tắt backup), đã review bảo mật; SRS v0.4.
- **13/10**: đổi phạm vi (chỉ LTTTBDD); sửa lỗi 26 câu thiếu hình (PDF dùng chung hình cho nhiều câu — phát hiện nhờ đối chiếu chéo 08/10, `docs/data/crosscheck-tasks.md`); validator thêm lỗi "câu nói tới hình mà không có hình"; roadmap Sprint 1 theo ngày.

- **14/10 — Code (đã push `dev`, merge `master` qua PR #1)**: ST-02 lưu trữ SQLite · ST-03 miễn trừ, chọn hạng (mô tả loại xe nguyên văn Luật 36/2024 Điều 57; đã kiểm Luật 118/2025 không sửa khoản 1) · ST-04 màn chính · ST-05 `QuestionView` 3 chế độ + phóng to hình · ST-06 học theo chủ đề (lưới câu, nhớ vị trí, "Làm lại") · ST-07 ôn câu sai / câu điểm liệt. Chi tiết: `production/stories/ST-0x.md`, `docs/reports/dev-log.md`.
- **14/10 — Team chạy được app**: đưa Gradle wrapper lên git (lỗi `GradleWrapperMain`); đổi tên 21 ảnh đối thủ (lỗi `Filename too long`); **chạy được bản web** (`sqflite_common_ffi_web`, ADR-002 cập nhật); `tools/check-setup.ps1` + `CONTRIBUTING.md` mục 2a. Đã kiểm từ bản clone mới: build APK và build web đều OK; debug web trên cổng 8080 chạy được.
- **14/10 — Sửa danh mục biển báo** theo soát của Kiệt (`data/sign-catalog/review-results/2026-10-14-kiet.json`, 29 lỗi): file sửa tay `data/sign-catalog/overrides.json` (mỗi mục ghi trang PDF), tên biển cao tốc theo bảng mục 46.8 QCVN, bỏ 8 mã thừa, thêm IE.455/IE.460/IE.464a, sửa thêm I.428a/b/c; còn **392 mục**; `validate_signs.py` thêm 4 luật chặn lỗi, PASS. Trang soát lần 2: `make_sign_review.py --fixed-only` → `review-fixed.html`.

- **15–23/10 — Hoàn thành Module A** (đã push `dev`, repo nộp `takidang/hoclaixe-app` cập nhật bằng `tools/publish-app-repo.ps1`): ST-08…ST-11 thi thử (chọn đề, làm bài, đồng hồ, bài dở, kết quả, xem lại, đề cố định) · ST-12/ST-16 danh mục 392 biển + tìm không dấu · ST-13 design system v0 · ST-15 thống kê, lịch sử thi, câu hay sai · chọn Sáng/Tối/Theo máy. Sửa 8 lỗi từ review code của Kiệt (High: đáp án lưu nhầm câu khi chuyển câu lúc đang lưu). Áp 3 lượt soát danh mục biển của Kiệt; vạch 3.2/3.3/3.4 có hình nhóm tự vẽ theo QCVN (ghi chú dưới hình). README viết lại, `docs/defense/tai-man-thi.md`, phiếu kiểm thử `docs/test/phieu-kiem-thu.docx` (32 mục).
- **30/10 — So với web mẫu của thầy (hoclaixefree.vercel.app)**, thêm 3 chức năng: **Câu đã lưu** (CSDL v2, có test nâng cấp), **Tìm câu hỏi** (số gốc / từ khóa không dấu), **Đọc câu hỏi** (`flutter_tts`, giọng tiếng Việt của máy). Giao diện v1 "Vạch kẻ đường" (`docs/design/DESIGN.md`, `LaneLine`). Review ponytail → sửa 5 mục (`5e23d62`). **Chạy thử trên máy ảo Android**: đọc tiếng Việt OK, dừng/đọc câu sau OK, tìm, lưu, nâng cấp CSDL giữ dữ liệu cũ.
- **30/10 — Giao diện v2 (đã merge `dev`)** theo mẫu Tài gửi (nền tối, thẻ gradient, thanh tab nổi): đã có theme v2 (tối mặc định, `AppGradients`), `GradientCard`/`SignBadge` (hình biển thật từ danh mục thay hình 3D của mẫu), thanh 4 tab (`StatefulShellRoute`: Tổng quan · Học · Câu đã lưu · Thống kê), tab Câu đã lưu, thẻ chủ đề gradient, biểu đồ "Số câu đã làm" 30 ngày + chuỗi ngày học ở tab Thống kê. Hoàn tất: sửa test theo thanh tab, test biểu đồ/chuỗi ngày/thanh tab, chữ thẻ đọc rõ ở nền tối, nút Back về Tổng quan; sửa hình biển P.127 (Hình B.27b trang 90).
- **30/10 — Thử nghiệm "ảnh xe" (Tài duyệt, đã merge `dev`)**: nền tối thẻ tông ngọc chữ trắng; màn mở đầu ảnh siêu xe + nút "Bắt đầu"; ảnh xe theo hạng ở màn chọn hạng và nền đầu Tổng quan; 4 ảnh Unsplash, nguồn ở `docs/design/photo-credits.md`. Chạy máy ảo OK.
- **30/10 — Chuyển động + tiện ích (đã merge `dev`)**: ảnh A1 Honda Air Blade (Wikimedia, CC BY-SA 4.0, chỉnh màu); ảnh "thở", thị sai, thẻ lún khi nhấn, chuyển màn iOS, chuyển tab mờ dần; nút viên thuốc đen/trắng; nhấn giữ thẻ chủ đề → thao tác nhanh; vuốt bỏ lưu + Hoàn tác; rung phản hồi; "Tự chuyển câu" (Giới thiệu + nút ⏩ khi đang làm).

## Việc tiếp theo (phiên sau bắt đầu từ đây)
1. Team `git pull` + `flutter pub get`, chạy thử bản giao diện mới trên máy thật (nhất là "Đọc câu hỏi" cần giọng tiếng Việt); ghi lỗi nếu có.
2. Repo nộp `hoclaixe-app` đang private → chuyển public khi nộp; chạy lần kiểm cuối từ bản clone mới.
3. Kiệt viết báo cáo LTTTBDD theo yêu cầu của thầy (`docs/reports/giang-vien/`, không đưa lên git); team điền phiếu kiểm thử.

## Phân công

| Người | Việc đang giao | Hạn |
|---|---|---|
| Tài | Kiểm bản cuối trên máy thật, chuyển repo nộp sang public khi nộp | trước khi nộp |
| Cả team | `git pull` rồi chạy app theo `CONTRIBUTING.md` mục 2a (web: `flutter run -d chrome --web-port 8080`) | ngay |
| Kiệt | Lấy yêu cầu format báo cáo, mẫu bìa của giảng viên LTTTBDD → `docs/reports/`; viết báo cáo LTTTBDD từ 19/10 (theo `docs/templates/report-ltttbdd.md`) | Mẫu: 16/10 · Báo cáo: 28/10 |
| Kiệt | Test thử app trên máy Android của mình từ khi có bản chạy được (ghi lỗi vào `production/bugs/`) | từ 19/10 |

## Blocker / cần bổ sung
- Đã quá hạn nội bộ 28/10 (hôm nay 30/10, buổi học cuối) — chưa có lịch nộp chính thức.
- Team thực tế 5 người (Tài nói "khoan hãy tính"): chưa cập nhật thông tin team trong `project-context.md`.
- "Đọc câu hỏi" chưa thử trên Chrome (bản web) và trên điện thoại thật chưa cài giọng tiếng Việt.
- Việc tạm dừng do đổi phạm vi (làm sau nếu còn thời gian): khảo sát người dùng, kho văn bản luật cho RAG, bộ ảnh kiểm tra biển báo.
