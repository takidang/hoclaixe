# Bối cảnh dự án

> File này là "trí nhớ chung" của studio. Cập nhật khi có quyết định mới.

## Sản phẩm

- **Tên app**: hoclaixe (app ôn thi bằng lái xe)
- **Mô tả**: Ôn thi lý thuyết sát hạch lái xe theo từng hạng bằng, dùng bộ câu hỏi mới nhất
  của Bộ Công an và luật giao thông hiện hành; có trợ lý AI giải thích luật/đáp án.
- **Nền tảng**: Android (chính) → Flutter Web (nếu dư thời gian, cùng codebase).

## Tech stack

- Flutter (Dart) + Android Studio
- State management: [CHỌN trong /create-architecture: Riverpod / Bloc / Provider]
- Lưu trữ local: [CHỌN: sqflite / drift / Hive / Isar]
- Backend: [CHỌN: Firebase (Auth, Firestore, Cloud Functions) / Supabase / server riêng]
- AI: Gemini API (gói miễn phí) + RAG trên kho văn bản luật & bộ câu hỏi.
  Gọi qua backend, không gọi thẳng từ app.
- Nhận diện biển báo: model phân loại TFLite chạy trên máy (huấn luyện bằng Python/Colab, transfer learning) + Gemini vision qua backend làm dự phòng và cho bản web.

## Hai đồ án dùng chung một sản phẩm

| | Đồ án LTTTBDD | Đồ án chuyên ngành CNPM |
|---|---|---|
| Trọng tâm | Kỹ thuật lập trình di động: Flutter, widget, state, local DB, điều hướng, offline, giao diện | Bài toán thực tế + AI + quy trình CNPM (Scrum, yêu cầu, thiết kế, kiểm thử, đánh giá) |
| Phạm vi | Module A — luyện đề như các app ôn thi trên Google Play, giao diện đẹp hơn; **không có AI** | Module A + B + D, tài liệu CNPM đầy đủ |
| Hạn | **28/10/2026** (hạn nội bộ tự đặt; trường chưa công bố lịch nộp, buổi học cuối 30/10/2026) | Chọn đề tài 05–11/10/2026 · Thực hiện 12/10–20/12/2026 · Nộp LMS 21–27/12/2026 · Bảo vệ 28/12/2026–10/01/2027 |

## Các module

| Module | Nội dung | Ưu tiên |
|---|---|---|
| **A — Lõi** | Chọn hạng bằng, học theo chủ đề, thi thử đúng cấu trúc đề và thời gian, câu điểm liệt, ôn câu sai, câu hay sai, danh mục biển báo, tra cứu luật, thống kê tiến độ | Must |
| **B — Chatbot AI** | Chatbot RAG giải thích luật/đáp án, **bắt buộc trích dẫn văn bản–điều–khoản**, cảnh báo AI 3 tầng, nút Báo sai | Must |
| **D — Nhận diện biển báo** | Chụp/chọn ảnh → model nhận diện → hiển thị biển chuẩn trong danh mục + tác dụng + câu hỏi liên quan; luồng "Nhận diện sai" và "Không nhận diện được" | Must (phương án dự phòng: Gemini vision) |
| B2 — Gợi ý ôn tập cá nhân hóa | Phân tích lịch sử làm bài → chủ đề yếu → bộ câu ôn | Could (hạ từ Should khi thêm Module D) |
| **C — Web** | Flutter Web từ cùng codebase; nhận diện biển báo trên web dùng đường Gemini | Could |

## Đối thủ đã khảo sát

App "Ôn thi GPLX 600 Câu" (Google Play):
- Khoảng 5 triệu lượt tải, 4,9 sao. Theo mô tả của app: bộ 600 câu do Cục CSGT phát hành, áp dụng từ 01/06/2025;
  chia theo hạng (A1/A 250 câu, B1 300 câu, các hạng còn lại 600 câu); 60 câu điểm liệt; học theo chuyên đề;
  thi thử bấm giờ; ôn câu sai; top 50 câu hay sai; danh mục biển báo; mẹo ghi nhớ.
  **Các con số này cần data-curator xác minh với nguồn chính thức trước khi dùng.**
- Có tuyên bố miễn trừ (sản phẩm độc lập, dẫn nguồn csgt.bocongan.gov.vn, csgt.vn).
- **Không có tính năng AI** (theo mô tả trên store) → khác biệt của mình nằm ở Module B và D.
- Người dùng phàn nàn đáp án đã chọn bị đổi khi nộp bài → phải có test case riêng cho việc lưu đáp án.

## Team

| | Thành viên 1 (trưởng nhóm) | Thành viên 2 |
|---|---|---|
| Họ tên | Đặng Lê Tấn Tài | Nguyễn Đỗ Tuấn Kiệt |
| MSSV | 2380601937 | 2380601147 |
| GitHub | `takidang` (chủ repo) | `hlo043097-cmd` (collaborator) |
| Vai trò chính | Backend (proxy Gemini, RAG, Firebase/Supabase) với Claude Code; Frontend Flutter, UI thiết kế bằng Claude Design | Tìm tài liệu/dữ liệu chính thức (bộ câu hỏi, luật, quy chuẩn biển báo); viết 2 báo cáo |
| Vai trò phụ | Huấn luyện model Module D (đề xuất, chưa chốt) | Khi có Claude Pro: phụ một phần design và backend, làm các chức năng phụ được giao |
| Agent hay dùng | technical-director, backend-developer, flutter-developer, ux-designer, ml-engineer | data-curator, report-writer; sau này thêm ux-designer, backend-developer |
| Công cụ AI | Claude Code, Claude Design | Chưa có Claude Pro (sẽ đăng ký sau) |

- Chụp ảnh biển báo cho Module D: cả hai cùng làm (đề xuất, chốt trong `/dataset-plan`).
- Năng lực: không cố định (ngày rảnh, ngày bận), tối thiểu **1 giờ/ngày/người** → lập kế hoạch sprint theo mức sàn
  ~7 giờ/tuần/người (~14 giờ/sprint/người); giờ làm thêm ngày rảnh coi là dư địa, không tính trước.
- Hướng dẫn cho thành viên mới clone repo: `CONTRIBUTING.md`.

## Mốc thời gian (đồ án chuyên ngành)

- Chọn đề tài: 05/10–11/10/2026
- Thực hiện: 12/10–20/12/2026 (10 tuần = 5 sprint × 2 tuần)
- Nộp báo cáo: 21/12–27/12/2026
- Bảo vệ: 28/12/2026–10/01/2027

## Yêu cầu của giảng viên

- Đề tài phải thực tế và dùng AI để giải quyết vấn đề.
- Được dùng AI hỗ trợ viết code.
- [ĐIỀN các yêu cầu về format báo cáo, số trang, mẫu bìa… khi có]

## Quyết định đã chốt

> Ghi theo dạng: `- YYYY-MM-DD: <quyết định> (xem ADR-xxx nếu có)`

- Dùng Gemini API miễn phí + RAG cho chatbot để hạn chế trả lời sai.
- 2026-10-03: Thêm Module D — chụp ảnh nhận diện biển báo; AI chỉ chọn mã biển, nội dung lấy từ danh mục chuẩn.
- 2026-10-03: Nhận diện = phân loại trên ảnh đã căn/cắt; có lớp "không phải biển báo"; on-device TFLite + Gemini vision dự phòng.
- 2026-10-03: Luồng nhận diện: được → so sánh cạnh hình chuẩn; "Nhận diện sai" → top 3–5 rồi tra danh mục; dưới ngưỡng → báo không nhận diện được + hướng dẫn chụp lại.
- 2026-10-03: Cảnh báo AI 3 tầng (hộp thoại lần đầu, dòng cố định + nút Kiểm chứng dưới mỗi câu trả lời, trích dẫn văn bản–điều–khoản) + nút Báo sai.
- 2026-10-03: Tuyên bố miễn trừ toàn app (sản phẩm độc lập, không đại diện cơ quan nhà nước, dẫn nguồn chính thức).
- 2026-10-03: Gợi ý ôn tập cá nhân hóa hạ xuống Could.
- 2026-10-03: Hạn nội bộ đồ án LTTTBDD 28/10/2026 (buổi học cuối 30/10). Phạm vi LTTTBDD = Module A luyện đề như app đối thủ, giao diện đẹp hơn, không AI. Camera/nhận diện, chatbot, tra cứu luật chuyển hết sang đồ án chuyên ngành (Sprint 2–5).
- 2026-10-03: Discovery (xem `docs/srs/vision.md`): MVP hỗ trợ hạng A1, A, B; hạng khác thêm sau bằng dữ liệu cấu hình.
- 2026-10-03: Cấu trúc đề thi là dữ liệu cấu hình theo hạng + ngày hiệu lực (đề hiện hành + đề từ 01/3/2027 theo TT 108/2026/TT-BCA, khi xác minh được nguyên văn).
- 2026-10-03: Won't: mẹo ghi nhớ (trái mục tiêu chống học mẹo, không có nguồn), thi mô phỏng/video. Tra cứu luật chỉ cho đồ án chuyên ngành.
- 2026-10-03: Có khảo sát người dùng (Google Form, ≥ 30 phản hồi, Kiệt phụ trách) — `docs/srs/survey.md`.
