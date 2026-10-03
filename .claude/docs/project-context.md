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
| Trọng tâm | Kỹ thuật lập trình di động: Flutter, widget, state, local DB, camera, chạy model trên máy | Bài toán thực tế + AI + quy trình CNPM (Scrum, yêu cầu, thiết kế, kiểm thử, đánh giá) |
| Phạm vi | Module A (+ phần camera/on-device của Module D) | Module A + B + D, tài liệu CNPM đầy đủ |
| Hạn | [ĐIỀN hạn nộp/bảo vệ LTTTBDD] | Chọn đề tài 05–11/10/2026 · Thực hiện 12/10–20/12/2026 · Nộp LMS 21–27/12/2026 · Bảo vệ 28/12/2026–10/01/2027 |

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

- Thành viên 1: [ĐIỀN tên — vai trò chính]
- Thành viên 2: [ĐIỀN tên — vai trò chính]
- Năng lực: khoảng [ĐIỀN] giờ/tuần/người

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
