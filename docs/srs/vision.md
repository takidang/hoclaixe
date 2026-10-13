# Tầm nhìn sản phẩm — hoclaixe

> Phase 1 — Discovery · Bản nháp 2026-10-03 · Chủ trì: product-director · Review: business-analyst, project-manager
> Trạng thái: đã duyệt 2026-10-03

**Một câu**: hoclaixe giúp người ôn thi lý thuyết lái xe hạng A1, A, B **hiểu** vì sao đáp án đúng (không học vẹt),
luôn dùng bộ đề và luật **hiện hành có nguồn chính thức**, và **nhận ra biển báo** gặp ngoài đường.

## 1. Vấn đề

| # | Vấn đề | Dẫn chứng |
|---|---|---|
| P1 | **Học vẹt, không hiểu.** Bộ 600 câu mới được thiết kế để chấm dứt "học mẹo, thi mẹo", nhiều câu tình huống thực tế; người học thuộc đáp án nhưng không biết căn cứ điều luật nào, dễ sai khi câu hỏi đổi cách hỏi. | Báo chí về bộ 600 câu của Cục CSGT (Tuổi Trẻ, Thanh Niên, 2025); Thông tư 108/2026/TT-BCA tiếp tục mục tiêu chống học mẹo. Khảo sát: [CẦN SỐ LIỆU: % người trả lời "thuộc đáp án nhưng không hiểu lý do"] |
| P2 | **Luật và đề thi thay đổi liên tục.** Trong 2 năm: Luật TTATGTĐB 2024 và NĐ 168/2024 (hiệu lực 01/01/2025), QCVN 41:2024 (01/01/2025), bộ 600 câu (01/6/2025, bắt buộc 01/9/2025), TT 108/2026/TT-BCA (01/7/2026; đề lý thuyết tăng số câu từ 01/3/2027). Tài liệu/app cũ lỗi thời, người học không biết nguồn nào đúng. | Các văn bản trên (xem `docs/data/sources.md` sau /data-plan). Khảo sát: [CẦN SỐ LIỆU] |
| P3 | **Khó nhớ và khó nhận ra biển báo.** Nhiều biển gần giống nhau; gặp biển lạ ngoài đường không biết tra thế nào (không gõ được tên biển). | Khảo sát: [CẦN SỐ LIỆU] |
| P4 | **Trải nghiệm app hiện có.** App miễn phí nhiều quảng cáo; có phản hồi đáp án đã chọn bị đổi khi nộp bài. | Đánh giá người dùng trên Google Play (README 3.1) |

## 2. Người dùng mục tiêu

| Nhóm | Đặc điểm | Nhu cầu chính |
|---|---|---|
| U1 — Sinh viên thi A1/A (chính) | 18–22 tuổi, học trên điện thoại lúc rảnh, hay mất mạng/tiết kiệm dữ liệu | Học nhanh theo chủ đề, thi thử nhiều lần, chạy offline, giao diện gọn |
| U2 — Người đi làm thi B (chính) | 22–40 tuổi, ít thời gian, học tối/cuối tuần | Lộ trình ngắn, biết mình yếu chủ đề nào, hiểu luật để lái an toàn thật |
| U3 — Người đã có bằng (phụ, chỉ đồ án chuyên ngành) | Muốn cập nhật luật mới, mức phạt, biển báo mới | Hỏi đáp luật có trích dẫn, nhận diện biển báo |

Kiểm chứng giả định người dùng bằng khảo sát (`docs/srs/survey.md`), mục tiêu ≥ 30 phản hồi trước 10/10/2026.

## 3. Phân tích đối thủ

| App | Tính năng nổi bật | Điểm yếu | Cơ hội cho mình |
|---|---|---|---|
| Ôn thi GPLX 600 Câu (WATERFALL) | ~5 triệu lượt tải, 4,9★; 600 câu theo hạng, 60 câu điểm liệt, thi thử bấm giờ, ôn câu sai, top 50 câu hay sai, biển báo, mẹo ghi nhớ | Không AI; có quảng cáo; phản hồi lỗi đáp án bị đổi khi nộp bài | Giải thích AI có trích dẫn; lưu đáp án tin cậy (có test riêng) |
| Ôn thi GPLX 600 Câu (Pro) (Works Nicely Ventures) | Không quảng cáo, tìm câu theo từ khóa, lưu câu sai | Không AI | Như trên |
| Ôn thi GPLX 600 câu & Mô phỏng (LLE) | 600 câu + 120 tình huống mô phỏng | Phần mô phỏng mất giá trị khi TT 108/2026 bỏ sát hạch mô phỏng từ 01/7/2026 [CẦN XÁC MINH nguyên văn] | Tập trung lý thuyết + hiểu luật |
| Ôn Thi GPLX 600 Câu Hỏi 2026 (OTOMOTO) | 600 câu, 60 câu điểm liệt | Không AI | Như trên |

Các con số về đối thủ lấy từ mô tả trên store, chưa kiểm chứng độc lập. **Theo mô tả store, chưa app nào có giải thích bằng AI kèm trích dẫn văn bản–điều–khoản hay nhận diện biển báo bằng ảnh.**

## 4. Giải pháp và giá trị khác biệt

| Vấn đề | Giải pháp | Vì sao tốt hơn cách hiện có |
|---|---|---|
| P1 | **Chatbot RAG** (Retrieval-Augmented Generation — truy xuất văn bản luật rồi mới cho Gemini trả lời) + nút "Hỏi AI về câu này" ngay trong màn hình câu hỏi | Giải thích theo ngữ cảnh câu hỏi, **bắt buộc trích dẫn văn bản–điều–khoản** lấy từ dữ liệu truy xuất; không đủ căn cứ → từ chối thay vì bịa |
| P2 | Dữ liệu có **nguồn + ngày hiệu lực**; **cấu trúc đề là dữ liệu cấu hình** theo hạng và ngày hiệu lực (đề hiện hành + đề từ 01/3/2027) | Cập nhật khi luật đổi mà không sửa code; người học thấy rõ đang ôn theo quy định nào |
| P3 | **Chụp ảnh nhận diện biển báo** (Gemini vision qua backend; model TFLite trên máy là hướng phát triển) | AI chỉ chọn mã biển, ý nghĩa lấy từ danh mục QCVN 41:2024 → không bao giờ bịa ý nghĩa |
| P4 | Giao diện Material 3 gọn, không quảng cáo, offline; lưu đáp án bền vững | Có bộ test bắt buộc cho việc giữ đáp án |

Nguyên tắc: **AI không bao giờ là nguồn sự thật** — cảnh báo AI 3 tầng, nút Báo sai, tuyên bố miễn trừ toàn app.

## 5. Phạm vi MVP (MoSCoW)

> **Đổi phạm vi 13/10/2026**: đồ án chuyên ngành đã đổi sang đề tài khác — hoclaixe **chỉ còn là đồ án LTTTBDD**.
> Ưu tiên duy nhất: **Module A làm giống app đối thủ, xong trước 28/10/2026**. Module B (chatbot), D (nhận diện biển),
> C (web) chuyển thành "làm sau nếu còn thời gian" — tài liệu, agent, skill phần AI giữ lại, không xóa.

Các dòng đánh dấu đồ án **CN** dưới đây chuyển thành "làm sau".

Đồ án: **LT** = LTTTBDD (hạn 28/10/2026) · **CN** = chuyên ngành (Module A cũng là phần lõi của CN).

| Tính năng | Module | Ưu tiên | Đồ án |
|---|---|---|---|
| Chọn hạng A1, A, B (hạng khác: chỉ thêm dữ liệu cấu hình, làm sau nếu dư thời gian) | A | Must | LT, CN |
| Cấu trúc đề là dữ liệu cấu hình theo hạng + ngày hiệu lực; đề hiện hành | A | Must | LT, CN |
| Đề theo cấu trúc từ 01/3/2027 (TT 108/2026) — TT 108 chỉ quy định tổng số câu/thời gian/điểm đạt, chưa có phân bổ theo chương, điểm liệt, bộ câu hỏi; làm khi Cục CSGT ban hành hướng dẫn | A | Could | CN |
| Học theo chủ đề/chương, xem đáp án đúng | A | Must | LT, CN |
| Thi thử: đề ngẫu nhiên đúng cấu trúc, đồng hồ đếm ngược, chấm điểm, **trượt khi sai câu điểm liệt** | A | Must | LT, CN |
| Lưu đáp án bền vững (chuyển câu, xoay màn hình, app vào nền, tắt app, nộp bài) | A | Must | LT, CN |
| Ôn câu sai; ôn riêng câu điểm liệt | A | Must | LT, CN |
| Danh mục biển báo theo nhóm (QCVN 41:2024) | A | Must | LT, CN |
| Tuyên bố miễn trừ + nguồn dữ liệu (màn hình Giới thiệu, lần mở đầu) | A | Must | LT, CN |
| Thống kê tiến độ (theo chủ đề, lịch sử thi thử) | A | Should | LT, CN |
| Câu hay sai **của chính người dùng** (đối thủ dùng số liệu toàn hệ thống — cần backend) | A | Should | LT, CN |
| Tìm câu hỏi theo từ khóa | A | Could | LT, CN |
| Chế độ tối (dark mode) | A | Could | LT, CN |
| Tra cứu luật (văn bản → điều → khoản) | A | Should | CN |
| Chatbot RAG giải thích luật/đáp án, trích dẫn bắt buộc | B | Must | CN |
| Nút "Hỏi AI về câu này" từ màn hình câu hỏi | B | Must | CN |
| Cảnh báo AI 3 tầng + nút Báo sai | B | Must | CN |
| Chụp/chọn ảnh → nhận diện biển bằng Gemini vision qua backend + 3 trạng thái kết quả | D | Must | CN |
| Model TFLite chạy trên máy (offline) cho nhóm biển phổ biến | D | Could (quyết lại 15/11) | CN |
| Gợi ý ôn tập cá nhân hóa theo chủ đề yếu (B2) | B | Could | CN |
| Đăng nhập + đồng bộ tiến độ lên cloud | — | Could | CN |
| Flutter Web | C | Could | CN |
| Mẹo ghi nhớ | — | Won't | — (trái mục tiêu chống học mẹo của bộ đề mới; không có nguồn chính thức) |
| Thi mô phỏng tình huống / video | — | Won't | — (ngoài phạm vi lý thuyết; TT 108/2026 bỏ sát hạch mô phỏng [CẦN XÁC MINH]) |
| Hạng C1, C, D, E… | A | Won't (đợt này) | — (thêm dữ liệu cấu hình sau) |

**Kiểm tra năng lực** (sàn 1 giờ/ngày/người):
- LT (04/10–28/10, ~25 ngày ≈ 50 giờ cho 2 người): 9 mục Must của Module A. Khả thi khi dùng Claude Code, **với điều kiện bộ câu hỏi nhập xong trước 15/10**. Should (thống kê, câu hay sai) là phần cắt đầu tiên nếu trễ. Đóng băng tính năng 25/10.
- CN (29/10–20/12, ~7,5 tuần ≈ 105 giờ): Module B + D Must + tra cứu luật. Module D dùng Gemini vision (~25 giờ) thay vì tự huấn luyện model (~40–60 giờ + thu thập ảnh). Rủi ro: hạn mức Gemini miễn phí, độ chính xác trên ảnh thật.

## 6. Tiêu chí thành công (đo được)

| # | Tiêu chí | Ngưỡng | Đo bằng |
|---|---|---|---|
| S1 | Mọi Must của Module A chạy trên máy Android thật | 100%, trước 28/10/2026 | Checklist demo + APK release |
| S2 | Chấm điểm + điểm liệt đúng cấu trúc từng hạng | 100% test case pass | Unit test |
| S3 | Giữ đáp án qua 6 kịch bản (chuyển câu, quay lại, xoay, vào nền, tắt app, nộp) | 100% pass | Widget/integration test + test thủ công |
| S4 | Module A dùng được hoàn toàn không mạng | 100% chức năng | Test thủ công chế độ máy bay |
| S5 | Dữ liệu câu hỏi có nguồn, đối chiếu chéo 2 người | 100% câu có nguồn; 0 sai khác chưa xử lý | Script kiểm tra dữ liệu |
| S6 | Chatbot: câu trả lời đúng trên bộ đánh giá; có trích dẫn hoặc từ chối | Đúng ≥ [CHỐT trong /rag-design]; 100% có trích dẫn hoặc từ chối | `/ai-eval` |
| S7 | Nhận diện biển báo trên ảnh thật | Top-1 ≥ [CHỐT trong /vision-design], top-3 ≥ [CHỐT] | `/ml-eval` |
| S8 | Không còn bug Critical/High khi nộp | 0 | `production/bugs/` |
| S9 | UAT với người đang ôn thi | ≥ 10 người; ≥ [CHỐT]% đánh giá giải thích AI giúp hiểu bài | Phiếu UAT |

## 7. Giả định và ràng buộc

**Giả định** (cần kiểm chứng):
- Người ôn thi muốn hiểu lý do đáp án chứ không chỉ thuộc — kiểm chứng bằng khảo sát.
- File bộ 600 câu trên csgt.vn đủ để nhập liệu (nội dung, đáp án, hình, chương, cờ điểm liệt, hạng áp dụng) — Kiệt xác nhận trước 08/10.
- Gói miễn phí Gemini đủ cho dev, đánh giá và demo (có cache, chạy theo lô, video dự phòng).

**Ràng buộc**:
- Team 2 người, tối thiểu 1 giờ/ngày/người; LTTTBDD hạn 28/10/2026; CN nộp 21–27/12/2026, bảo vệ 28/12/2026–10/01/2027.
- Android là nền tảng chính; web là tùy chọn.
- API key chỉ ở backend; ảnh người dùng không lưu trên server.
- Chỉ dùng dữ liệu từ nguồn chính thức; app là sản phẩm độc lập, không đại diện cơ quan nhà nước.

**Đã xác minh 04/10/2026** (xem `docs/data/sources.md` §3): cấu trúc đề hiện hành A1, A, B theo chương (CV 2262),
thời gian và điểm đạt (TT 12/2025, còn hiệu lực đến 28/02/2027), điều khoản chuyển tiếp và cấu trúc từ 01/3/2027 (TT 108/2026).
TT 108 không nhắc tới điểm liệt và không ban hành bộ câu hỏi mới. File bộ 600 câu trên csgt.bocongan.gov.vn là PDF chữ —
đã trích xuất tự động đủ 600 câu (`tools/extract_questions/`).

**Còn chưa xác minh**: việc TT 108/2026 bỏ sát hạch mô phỏng (chỉ có nguồn thứ cấp).

## Nguồn tham khảo (truy cập 03/10/2026)
- Tuổi Trẻ — Bộ 600 câu lý thuyết sát hạch lái xe mới có gì khác với bộ cũ?: https://tuoitre.vn/video/bo-600-cau-ly-thuyet-sat-hach-lai-xe-moi-co-gi-khac-voi-bo-cu-181739.htm
- Thanh Niên — Từ 1.9, tất cả kỳ thi sát hạch lái xe dùng bộ đề 600 câu của CSGT: https://thanhnien.vn/tu-19-tat-ca-ky-thi-sat-hach-lai-xe-dung-bo-de-600-cau-cua-csgt-185250903093312504.htm
- Cục CSGT — Bộ 600 câu hỏi dùng cho sát hạch lái xe cơ giới đường bộ: https://www.csgt.vn/m/vanbanphapluat/319/Bo-600-cau-hoi-danh-cho-sat-hach-lai-xe-co-gioi-duong-bo.html
- Cấu trúc đề từ 01/6/2025 (thứ cấp): https://thuvienphapluat.vn/chinh-sach-phap-luat-moi/vn/ho-tro-phap-luat/chinh-sach-moi/84650/chi-tiet-cau-truc-de-thi-ly-thuyet-lai-xe-o-to-cac-hang-tu-ngay-01-6-2025
- Thông tư 108/2026/TT-BCA (thứ cấp): https://luatvietnam.vn/linh-vuc-khac/diem-moi-thong-tu-108-2026-tt-bca-ve-sat-hach-cap-giay-phep-lai-xe-va-quoc-te-883-110169-article.html
- Cổng TTĐT Chính phủ — quy định mới về sát hạch từ 01/7/2026: https://xaydungchinhsach.chinhphu.vn/quy-dinh-moi-bo-phan-sat-hach-lai-xe-mo-phong-tu-01-7-2026-119260627105803901.htm
- QCVN 41:2024/BGTVT: https://luatvietnam.vn/giao-thong/quy-chuan-qcvn-412024-bgtvt-bao-hieu-duong-bo-376856-d3.html
- Bộ Công an — mức xử phạt từ 01/01/2025 (NĐ 168/2024): https://bocongan.gov.vn/chinh-sach-phap-luat/bai-viet/muc-xu-phat-vi-pham-hanh-chinh-ve-trat-tu-an-toan-giao-thong-duong-bo-tu-01012025-d1-t1624
- Google Play: com.waterfall.trafficlaws2, com.waterfall.trafficlawspro, com.lle.gplx, com.ang.onthigplx
