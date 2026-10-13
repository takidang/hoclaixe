# Bối cảnh dự án

> File này là "trí nhớ chung" của studio. Cập nhật khi có quyết định mới.

## Sản phẩm

- **Tên app**: hoclaixe (app ôn thi bằng lái xe)
- **Mô tả**: Ôn thi lý thuyết sát hạch lái xe theo từng hạng bằng, dùng bộ câu hỏi mới nhất
  của Bộ Công an và luật giao thông hiện hành; có trợ lý AI giải thích luật/đáp án.
- **Nền tảng**: Android (chính) → Flutter Web (nếu dư thời gian, cùng codebase).

## Tech stack

- Flutter (Dart) + Android Studio
- State management: **Riverpod** (ADR-001)
- Lưu trữ local: **sqflite** cho dữ liệu người học (ADR-002); nội dung câu hỏi/đề/biển là JSON đóng gói chỉ đọc (ADR-003)
- Backend: **không có** cho Module A (ADR-004); điều hướng go_router (ADR-005); tắt sao lưu Android (ADR-006). Kiến trúc: `docs/architecture/architecture.md`
- AI: Gemini API (gói miễn phí) + RAG trên kho văn bản luật & bộ câu hỏi.
  Gọi qua backend, không gọi thẳng từ app.
- Nhận diện biển báo: **Gemini vision qua backend** (chọn đúng một mã trong danh mục hoặc `UNKNOWN`); model TFLite chạy trên máy là hướng mở rộng (Could, quyết lại 15/11).

## Phạm vi đồ án

> **Đổi phạm vi 13/10/2026**: đồ án chuyên ngành đã đổi sang đề tài khác — hoclaixe **chỉ còn là đồ án LTTTBDD**.
> Ưu tiên duy nhất: **Module A làm giống app đối thủ, xong trước 28/10/2026**. Module B (chatbot), D (nhận diện biển),
> C (web) chuyển thành "làm sau nếu còn thời gian" — tài liệu, agent, skill phần AI giữ lại, không xóa.

| | Đồ án LTTTBDD |
|---|---|
| Trọng tâm | Kỹ thuật lập trình di động: Flutter, widget, state, local DB, điều hướng, offline, giao diện |
| Phạm vi | Module A — luyện đề như các app ôn thi trên Google Play, giao diện đẹp hơn; **không có AI** |
| Hạn | **28/10/2026** (hạn nội bộ tự đặt; trường chưa công bố lịch nộp, buổi học cuối 30/10/2026) |

## Các module

| Module | Nội dung | Ưu tiên |
|---|---|---|
| **A — Lõi** | Must: chọn hạng (A1, A, B), học theo chủ đề, thi thử đúng cấu trúc đề và thời gian, câu điểm liệt, ôn câu sai, danh mục biển báo, tuyên bố miễn trừ · Should: thống kê tiến độ, câu hay sai của người dùng · Should (chỉ chuyên ngành): tra cứu luật. Chi tiết: `docs/srs/vision.md` §5 | Must |
| **B — Chatbot AI** | Chatbot RAG giải thích luật/đáp án, **bắt buộc trích dẫn văn bản–điều–khoản**, cảnh báo AI 3 tầng, nút Báo sai | Làm sau (từ 13/10) |
| **D — Nhận diện biển báo** | Chụp/chọn ảnh → model nhận diện → hiển thị biển chuẩn trong danh mục + tác dụng + câu hỏi liên quan; luồng "Nhận diện sai" và "Không nhận diện được" | Làm sau (từ 13/10) — nếu làm: Gemini vision là phương án chính |
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

- Ảnh biển báo cho Module D: chỉ cần **bộ ảnh kiểm tra** (~100–200 ảnh, ưu tiên bộ dữ liệu công khai có giấy phép + vài chục ảnh tự chụp đối chứng) — không thu thập dữ liệu huấn luyện.
- Năng lực: không cố định (ngày rảnh, ngày bận), tối thiểu **1 giờ/ngày/người** → lập kế hoạch sprint theo mức sàn
  ~7 giờ/tuần/người (~14 giờ/sprint/người); giờ làm thêm ngày rảnh coi là dư địa, không tính trước.
- Hướng dẫn cho thành viên mới clone repo: `CONTRIBUTING.md`.

## Mốc thời gian

- **LTTTBDD: hạn nội bộ 28/10/2026** (xem `production/roadmap.md`).

Mốc cũ của đồ án chuyên ngành (không còn áp dụng cho repo này từ 13/10/2026):

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
- 2026-10-03: Nhận diện = phân loại trên ảnh đã căn/cắt; có kết quả "không phải biển báo / không nhận diện được".
- 2026-10-06: **Module D dùng Gemini vision làm phương án chính** (không phải dự phòng); model TFLite trên máy hạ xuống Could (quyết lại 15/11 nếu dư thời gian), nêu là hướng phát triển trong báo cáo. Lý do: không đủ thời gian thu thập/gán nhãn hàng nghìn ảnh và huấn luyện ~300 lớp. Mua Google AI Pro không tăng hạn mức Gemini API — dùng gói miễn phí, chỉ bật Tier 1 (trả theo dùng) khi chạm giới hạn.
- 2026-10-03: Luồng nhận diện: được → so sánh cạnh hình chuẩn; "Nhận diện sai" → top 3–5 rồi tra danh mục; dưới ngưỡng → báo không nhận diện được + hướng dẫn chụp lại.
- 2026-10-03: Cảnh báo AI 3 tầng (hộp thoại lần đầu, dòng cố định + nút Kiểm chứng dưới mỗi câu trả lời, trích dẫn văn bản–điều–khoản) + nút Báo sai.
- 2026-10-03: Tuyên bố miễn trừ toàn app (sản phẩm độc lập, không đại diện cơ quan nhà nước, dẫn nguồn chính thức).
- 2026-10-03: Gợi ý ôn tập cá nhân hóa hạ xuống Could.
- 2026-10-03: Hạn nội bộ đồ án LTTTBDD 28/10/2026 (buổi học cuối 30/10). Phạm vi LTTTBDD = Module A luyện đề như app đối thủ, giao diện đẹp hơn, không AI. Camera/nhận diện, chatbot, tra cứu luật chuyển hết sang đồ án chuyên ngành (Sprint 2–5).
- 2026-10-03: Discovery (xem `docs/srs/vision.md`): MVP hỗ trợ hạng A1, A, B; hạng khác thêm sau bằng dữ liệu cấu hình.
- 2026-10-03: Cấu trúc đề thi là dữ liệu cấu hình theo hạng + ngày hiệu lực (`data/question-bank/exam-structures.json`).
- 2026-10-04: Đề hiện hành theo CV 2262/CSGT-P5 + TT 12/2025 (hiệu lực đến 28/02/2027). Đề từ 01/3/2027 (TT 108/2026) hạ xuống Could: chưa có phân bổ chương, điểm liệt, bộ câu hỏi.
- 2026-10-04: Bộ 600 câu trích xuất tự động từ PDF chính thức (`tools/extract_questions/`); điểm liệt tính theo hạng (`criticalFor`: B+ 60 câu, A1/A 20, B1 30). Nguồn: `docs/data/sources.md`.
- 2026-10-03: Won't: mẹo ghi nhớ (trái mục tiêu chống học mẹo, không có nguồn), thi mô phỏng/video. Tra cứu luật chỉ cho đồ án chuyên ngành.
- 2026-10-13: **Đổi phạm vi** — đồ án chuyên ngành đổi đề tài khác; hoclaixe chỉ còn là đồ án LTTTBDD. Làm Module A giống đối thủ trước 28/10; B, C, D làm sau nếu còn thời gian.
- 2026-10-13: `/create-architecture` — Riverpod, sqflite, nội dung JSON đóng gói, không backend, go_router, tắt backup Android (ADR-001…006). Không hiện nhãn điểm liệt khi đang thi; "Câu sai" bỏ ra khi đúng 2 lần liên tiếp. Tham khảo `tdytools-gplx` (React/PWA, không giấy phép) chỉ lấy ý tưởng.
- 2026-10-13: Sửa lỗi 26 câu thiếu hình (PDF dùng chung một hình cho nhiều câu) — phát hiện nhờ đối chiếu chéo ngày 08/10.
- 2026-10-03: Có khảo sát người dùng (Google Form, ≥ 30 phản hồi, Kiệt phụ trách) — `docs/srs/survey.md`.
