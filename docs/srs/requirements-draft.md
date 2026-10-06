# Bản nháp yêu cầu (đầu vào cho /write-srs)

## Toàn app
- FR-GEN-01: Lần mở app đầu tiên và màn hình Giới thiệu hiển thị tuyên bố miễn trừ: sản phẩm độc lập, không đại diện cơ quan nhà nước,
  nguồn dữ liệu (tên văn bản, ngày hiệu lực), link nguồn chính thức.

## Module B — Chatbot
- FR-AI-01: Lần đầu mở chatbot hiển thị hộp thoại cảnh báo AI có thể sai; phải bấm "Tôi đã hiểu" mới dùng được; ghi nhận đã xác nhận.
- FR-AI-02: Dưới mỗi câu trả lời có dòng cảnh báo cố định và nút "Kiểm chứng" mở trang chính thức của Bộ Công an.
- FR-AI-03: Mỗi câu trả lời liệt kê nguồn (văn bản, điều, khoản) lấy từ dữ liệu truy xuất; câu trả lời không có nguồn không được hiển thị như câu trả lời bình thường.
- FR-AI-04: Không tìm thấy căn cứ đủ liên quan → trả lời "không tìm thấy căn cứ" và gợi ý tra cứu.
- FR-AI-05: Nút "Báo sai" dưới mỗi câu trả lời; người dùng có thể ghi chú lý do.

## Module D — Nhận diện biển báo
- FR-SIGN-01: Người dùng chụp ảnh hoặc chọn ảnh từ thư viện; có khung hướng dẫn; cho cắt ảnh trước khi nhận diện.
- FR-SIGN-02: Độ tin cậy ≥ ngưỡng → hiển thị ảnh người dùng cạnh hình biển chuẩn, mã, tên, nhóm, tác dụng (từ danh mục), câu hỏi thi liên quan, nút hỏi chatbot về biển này, dòng cảnh báo "kết quả có thể sai — hãy so sánh hình".
- FR-SIGN-03: Nút "Nhận diện sai" → hiển thị 3–5 ứng viên tiếp theo; vẫn sai → tra danh mục theo nhóm và tự chọn.
- FR-SIGN-04: Với sự đồng ý của người dùng, ghi lại lựa chọn đúng sau khi bấm "Nhận diện sai" (phục vụ đánh giá và huấn luyện lại).
- FR-SIGN-05: Dưới ngưỡng hoặc lớp "không phải biển báo" → thông báo "Không nhận diện được biển báo", gợi ý cách chụp, nút Chụp lại và Tra danh mục.
- FR-SIGN-06: Nhận diện qua Gemini vision cần mạng; trước khi gửi ảnh lần đầu, thông báo cho người dùng ảnh sẽ được gửi lên máy chủ để nhận diện (không lưu ảnh). Không có mạng → báo "Cần kết nối mạng để nhận diện" + nút Tra danh mục. *(Bản cũ: on-device offline — hạ xuống Could ngày 06/10/2026.)*
- BR-SIGN-01: Nội dung hiển thị về biển báo chỉ lấy từ danh mục chuẩn, không lấy từ đầu ra của model AI.
- NFR-SIGN-01: Thời gian từ lúc gửi ảnh tới khi có kết quả ≤ [ĐIỀN, ví dụ 5 giây] với mạng 4G ổn định (chốt trong vision-design).
- NFR-SIGN-02: Độ chính xác top-1 ≥ [ĐIỀN] và top-3 ≥ [ĐIỀN] trên tập test ảnh thật (chốt trong vision-design).

## Test bắt buộc (cho qa-engineer)
- Đáp án đã chọn được giữ nguyên khi: chuyển câu, quay lại câu cũ, xoay màn hình, app vào nền, tắt app giữa bài, nộp bài
  (bài học từ phản hồi người dùng app đối thủ).
- Trượt khi sai câu điểm liệt dù đủ điểm; đúng số câu và thời gian theo hạng.
- Chatbot: câu ngoài phạm vi, câu mơ hồ, prompt injection, hết quota, mất mạng.
- Nhận diện: ảnh rõ, ảnh mờ/tối/nghiêng, ảnh có nhiều biển, ảnh không có biển, từ chối quyền camera, chọn ảnh thư viện, máy không mạng.
- labels.txt khớp danh mục biển báo.
