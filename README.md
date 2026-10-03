# Claude Code App Studio — Flutter + AI

Biến Claude Code thành một "công ty làm app" ảo phục vụ hai đồ án dùng chung một sản phẩm:

- **Đồ án Lập trình trên thiết bị di động (LTTTBDD)**
- **Đồ án chuyên ngành Công nghệ Phần mềm** (yêu cầu đề tài thực tế, dùng AI giải quyết vấn đề)

Sản phẩm: **app ôn thi lý thuyết sát hạch lái xe** theo từng hạng bằng, dùng bộ câu hỏi mới nhất của Bộ Công an
và luật giao thông hiện hành, có **chatbot AI (Gemini + RAG) giải thích luật/đáp án** và **chụp ảnh nhận diện biển báo**.

Cấu trúc lấy cảm hứng từ [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) (MIT), thu gọn và viết lại cho làm app.

---

## 1. Bối cảnh

| | Đồ án LTTTBDD | Đồ án chuyên ngành CNPM |
|---|---|---|
| Trọng tâm | Kỹ thuật lập trình di động: Flutter, widget, state, local DB, điều hướng, offline, giao diện | Bài toán thực tế + AI + quy trình CNPM (Scrum, yêu cầu, thiết kế, kiểm thử, đánh giá) |
| Phạm vi | Module A — luyện đề như các app ôn thi trên Google Play, giao diện đẹp hơn; **không có AI** | Module A + B + D, tài liệu CNPM đầy đủ |
| Hạn | 28/10/2026 (hạn nội bộ; buổi học cuối 30/10/2026) | Chọn đề tài 05–11/10/2026 · Thực hiện 12/10–20/12/2026 · Nộp LMS 21–27/12/2026 · Bảo vệ 28/12/2026–10/01/2027 |

- Team 2 người. Giảng viên cho phép dùng AI hỗ trợ viết code.
- Công cụ: Flutter (Dart) + Android Studio; Gemini API gói miễn phí; Python + Google Colab để huấn luyện model.

## 2. Các module

| Module | Nội dung | Ưu tiên |
|---|---|---|
| **A — Lõi** | Must: chọn hạng (A1, A, B), học theo chủ đề, thi thử đúng cấu trúc đề và thời gian, câu điểm liệt, ôn câu sai, danh mục biển báo, tuyên bố miễn trừ · Should: thống kê tiến độ, câu hay sai của người dùng · Should (chỉ chuyên ngành): tra cứu luật. Chi tiết: `docs/srs/vision.md` §5 | Must |
| **B — Chatbot AI** | Chatbot RAG giải thích luật/đáp án, **bắt buộc trích dẫn văn bản–điều–khoản**, cảnh báo AI 3 tầng, nút Báo sai | Must |
| **D — Nhận diện biển báo** | Chụp/chọn ảnh → model nhận diện → hiển thị biển chuẩn trong danh mục + tác dụng + câu hỏi liên quan; luồng "Nhận diện sai" và "Không nhận diện được" | Must (phương án dự phòng: Gemini vision) |
| B2 — Gợi ý ôn tập cá nhân hóa | Phân tích lịch sử làm bài → chủ đề yếu → bộ câu ôn | Could (hạ từ Should khi thêm Module D) |
| **C — Web** | Flutter Web từ cùng codebase; nhận diện biển báo trên web dùng đường Gemini | Could |

## 3. Quyết định thiết kế đã chốt

### 3.1 Phân tích đối thủ (app "Ôn thi GPLX 600 Câu", Google Play)

- Khoảng 5 triệu lượt tải, 4,9 sao. Theo mô tả của app: bộ 600 câu do Cục CSGT phát hành, áp dụng từ 01/06/2025;
  chia theo hạng (A1/A 250 câu, B1 300 câu, các hạng còn lại 600 câu); 60 câu điểm liệt; học theo chuyên đề;
  thi thử bấm giờ; ôn câu sai; top 50 câu hay sai; danh mục biển báo; mẹo ghi nhớ. **Các con số này phải được
  data-curator xác minh lại với nguồn chính thức trước khi dùng.**
- App có tuyên bố miễn trừ: sản phẩm độc lập, không đại diện cơ quan nhà nước, dẫn nguồn đối chiếu chính thức
  (csgt.bocongan.gov.vn, csgt.vn).
- **Không có tính năng AI** (theo mô tả trên store) → khác biệt của mình nằm ở Module B và D.
- Bài học từ đánh giá người dùng: có phàn nàn đáp án đã chọn bị đổi khi nộp bài → lỗi lưu đáp án phá hỏng niềm tin,
  phải có test case riêng.

### 3.2 Tuyên bố miễn trừ toàn app

Màn hình Giới thiệu + lần mở app đầu tiên: app là sản phẩm độc lập (đồ án sinh viên), không đại diện Bộ Công an
hay cơ quan nhà nước nào; dữ liệu tham khảo từ nguồn chính thức (ghi tên văn bản, ngày hiệu lực); link nguồn đối chiếu.

### 3.3 Cảnh báo AI — 3 tầng

1. **Lần đầu mở chatbot**: hộp thoại giải thích AI có thể sai, phải bấm "Tôi đã hiểu" mới dùng được.
2. **Dưới mỗi câu trả lời**: dòng cố định "Thông tin do AI tạo, có thể sai sót. Hãy kiểm chứng với nguồn chính thức."
   + nút **Kiểm chứng** mở trang chính thức của Bộ Công an.
3. **Trích dẫn cụ thể**: mỗi câu trả lời liệt kê văn bản–điều–khoản lấy từ metadata truy xuất (không để model tự viết nguồn).

Thêm nút **Báo sai** dưới mỗi câu trả lời → dữ liệu đưa vào bộ đánh giá `/ai-eval`.
Không đủ căn cứ (dưới ngưỡng truy xuất) → trả lời "không tìm thấy căn cứ", không gọi model đoán.

### 3.4 Luồng nhận diện biển báo

Nguyên tắc cốt lõi: **AI chỉ chọn biển, nội dung lấy từ danh mục chuẩn** → kết quả luôn là một biển có thật,
ý nghĩa không bao giờ bị bịa.

1. **Chụp/chọn ảnh** có khung hướng dẫn đặt biển vào giữa; cho cắt ảnh khi có nhiều biển.
2. **Nhận diện được** (độ tin cậy ≥ ngưỡng): ảnh người dùng **đặt cạnh** hình biển chuẩn; hiện mã biển, tên, nhóm
   (cấm / nguy hiểm / hiệu lệnh / chỉ dẫn / phụ), tác dụng, các câu hỏi thi liên quan, nút hỏi chatbot về biển này.
   Kèm dòng cảnh báo nhẹ "Kết quả nhận diện có thể sai — hãy so sánh hình".
3. **"Nhận diện sai"**: hiện 3–5 ứng viên tiếp theo; vẫn sai → tự tìm trong danh mục theo nhóm. Lựa chọn của người
   dùng được ghi lại (có hỏi đồng ý) để đo độ chính xác thực tế và huấn luyện lại.
4. **Không nhận diện được** (dưới ngưỡng hoặc lớp "không phải biển báo"): báo rõ "Không nhận diện được biển báo",
   gợi ý chụp lại (gần hơn, đủ sáng, biển chiếm phần lớn khung hình), nút Chụp lại và Tra danh mục.

Kỹ thuật:
- Bài toán **phân loại** trên ảnh đã căn/cắt (không làm phát hiện thời gian thực — để "hướng phát triển").
- Phạm vi lớp: các biển xuất hiện trong bộ câu hỏi thi + lớp **"không phải biển báo"**.
- Model chính: transfer learning (MobileNet/EfficientNet-Lite…) → TFLite, chạy **trên máy, offline**.
- Dự phòng / bản web: Gemini vision qua backend, **bắt buộc trả về đúng một mã biển trong danh sách hoặc `UNKNOWN`**.
- Kết hợp: on-device trước; độ tin cậy thấp → hỏi Gemini hoặc hiện top-3.
- Đánh giá: top-1, top-3, tỷ lệ từ chối đúng, confusion matrix, thời gian suy luận; so sánh on-device vs Gemini vs kết hợp.
- Rủi ro lớn nhất là dữ liệu ảnh: nếu đến mốc 15/11 (giữa Sprint 3) chưa đủ ảnh có nhãn → chuyển Gemini vision làm phương án chính.

## 4. Cài đặt

1. Cài [Claude Code](https://code.claude.com/docs) và đăng nhập.
2. Windows: cài **Git for Windows** (hook chạy bằng `bash`).
3. Cài Flutter SDK + Android Studio, chạy `flutter doctor` cho sạch.
4. (Module D) Python 3 + tài khoản Google Colab để huấn luyện.
5. Giải nén bộ này làm thư mục gốc repo đồ án, `git init`, mở terminal tại đó, chạy `claude`.
6. Lần đầu: gõ `/start`.

## 5. Quy trình

| Phase | Lệnh |
|---|---|
| 0. Khởi động | `/start` |
| 1. Discovery | `/discovery` → `/gate-check discovery` |
| 2. Yêu cầu | `/write-srs` (dùng `docs/srs/requirements-draft.md` làm đầu vào) → `/gate-check requirements` |
| 3. Thiết kế | `/ux-design all`, `/data-plan`, `/rag-design`, `/vision-design`, `/dataset-plan`, `/create-architecture`, `/adr <...>` → `/gate-check design` |
| 4. Chuẩn bị | `/setup-flutter`, `/create-stories`, `/sprint-plan new` |
| 5. Phát triển (mỗi sprint) | `/dev-story ST-xx` → `/code-review` → `/story-done ST-xx`; `/ml-train` (Module D); cuối sprint `/sprint-plan close`, `/retro` |
| 6. Kiểm thử | `/test-plan`, `/ai-eval`, `/ml-eval`, `/bug-report` |
| 7. Phát hành | `/release-checklist`, `/web-port` (nếu dư thời gian) |
| 8. Báo cáo & bảo vệ | `/write-report ltttbdd\|chuyen-nganh`, `/defense-prep ...` |

Bất cứ lúc nào: `/status`.

## 6. Roadmap

| Thời gian | Sprint | Mục tiêu |
|---|---|---|
| 03/10–11/10 | 0 | /start, /discovery, chốt đề tài · SRS Module A · UX Module A (Claude Design) · kiến trúc app tối giản (state, local DB) · /setup-flutter · **Kiệt: tìm nguồn chính thức + bắt đầu nhập bộ câu hỏi** |
| 12/10–28/10 | 1 | **Nộp LTTTBDD 28/10** — Module A: chọn hạng, học theo chủ đề, thi thử + chấm điểm + điểm liệt (12–20/10) · ôn câu sai, câu hay sai, danh mục biển báo, thống kê (21–25/10) · test, build APK, hoàn thiện báo cáo LTTTBDD (26–28/10). Kiệt: nhập liệu xong trước 15/10, viết báo cáo LTTTBDD từ 19/10 |
| 29/10–08/11 | 2 | Thiết kế phần AI: SRS đủ Module B + D, rag-design, vision-design, dataset-plan, kiến trúc backend · Kiệt: kho văn bản luật, danh mục biển báo · **bắt đầu thu thập ảnh biển báo** |
| 09/11–22/11 | 3 | Backend + RAG prototype · tra cứu luật · **Huấn luyện model lần 1** · tích hợp TFLite + màn hình camera · **mốc quyết định dữ liệu ảnh 15/11** |
| 23/11–06/12 | 4 | Chatbot hoàn chỉnh + cảnh báo 3 tầng · luồng nhận diện sai/không nhận diện · /ai-eval, /ml-eval lần 1 |
| 07/12–20/12 | 5 | Ổn định, test, đánh giá cuối, release, (web nếu dư) — **không thêm tính năng** |
| 21/12–27/12 | — | Nộp báo cáo chuyên ngành |
| 28/12–10/01 | — | Bảo vệ |

Báo cáo LTTTBDD viết trong Sprint 1; báo cáo chuyên ngành viết song song từ Sprint 2.

## 7. Studio gồm những gì

- **14 agent**: product-director, technical-director, project-manager, business-analyst, ux-designer,
  flutter-developer, backend-developer, ai-engineer, **ml-engineer**, data-curator, qa-engineer,
  security-reviewer, release-engineer, report-writer.
- **28 skill**: start, status, discovery, write-srs, ux-design, create-architecture, adr, data-plan, rag-design,
  **vision-design, dataset-plan, ml-train, ml-eval**, setup-flutter, create-stories, sprint-plan, dev-story,
  code-review, story-done, retro, test-plan, ai-eval, bug-report, gate-check, release-checklist, web-port,
  write-report, defense-prep.
- **Rules** theo thư mục: Flutter, test, backend/AI, dữ liệu, tài liệu, **ML**.
- **Hooks**: tóm tắt trạng thái đầu phiên, chặn commit lộ API key/file nhạy cảm, tự format Dart.
- **Templates**: vision, SRS, use case, screen spec, architecture, ADR, data schema, RAG design, **vision design**,
  story, sprint, test plan, bug, dàn ý 2 báo cáo.

```
CLAUDE.md                 luật chung cho mọi phiên
.claude/agents|skills|rules|hooks|docs
docs/                     srs, architecture/adr, ux, ai, ml, data, test, reports, templates
production/               roadmap, backlog, stories, sprints, bugs, status, risks, ideas
data/                     question-bank, law-corpus, sign-catalog
ml/                       notebooks, scripts, dataset (không commit ảnh lớn), models, eval
src/                      app (Flutter), backend
```

## 8. Nguyên tắc bắt buộc

- **Dữ liệu chính thức**: câu hỏi, luật, danh mục biển báo chỉ lấy từ nguồn chính thức, có số hiệu và ngày hiệu lực.
  Agent bị cấm tự soạn từ trí nhớ.
- **API key** chỉ nằm ở backend (biến môi trường). Hook chặn commit nếu phát hiện key.
- **AI không bao giờ là nguồn sự thật**: chatbot phải trích dẫn; nhận diện biển chỉ chọn mã, nội dung lấy từ danh mục.
- **Bạn là người quyết định**: agent hỏi trước khi ghi file, không tự commit. Hiểu code AI viết — hội đồng sẽ hỏi.
- Gói miễn phí Gemini có giới hạn và có thể thay đổi → luôn có video demo dự phòng.
- Kiểm tra quy định khai báo việc dùng AI hỗ trợ trong báo cáo.
- Hai báo cáo cùng sản phẩm nhưng khác trọng tâm — không nộp hai bản giống nhau.
