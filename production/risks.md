# Danh sách rủi ro

| # | Rủi ro | Khả năng / Ảnh hưởng | Phòng ngừa / Ứng phó | Người theo dõi | Trạng thái |
|---|---|---|---|---|---|
| R-01 | Bộ ảnh kiểm tra biển báo lấy từ mạng quá "sạch" → đánh giá cao hơn thực tế; ảnh không rõ giấy phép | TB / TB | Ưu tiên bộ dữ liệu công khai có giấy phép, ghi nguồn từng ảnh; thêm 10–20 ảnh tự chụp đối chứng; nêu hạn chế trong báo cáo | ml-engineer | Mở |
| R-02 | Gemini vision nhận sai trên ảnh thật (góc chụp, ánh sáng, biển giống nhau) | TB / Cao | Ép trả về 1 mã trong danh sách hoặc `UNKNOWN`; hiện top-3 + tra danh mục; luôn đặt cạnh hình chuẩn để người dùng so sánh | ai-engineer | Mở |
| R-03 | Quota Gemini không đủ cho đánh giá/demo | TB / TB | Chạy theo lô, cache, video demo dự phòng | ai-engineer | Mở |
| R-04 | Tài ôm cả backend, frontend và ML → quá tải, trễ sprint | Cao / Cao | Ưu tiên Must, cắt Could sớm; Kiệt nhận phụ design/backend khi có Claude Pro; theo dõi mỗi sprint | project-manager | Mở |
| R-05 | Kiệt chưa có Claude Pro → khó nhận việc code, lệch khối lượng giữa 2 người | TB / TB | Giao việc dữ liệu + báo cáo không cần Claude Pro trước; chốt ngày đăng ký Claude Pro | project-manager | Mở |
| R-06 | Nguồn dữ liệu chính thức không có định dạng máy đọc được → phải nhập tay, dễ sai | Cao / TB | Bắt đầu nhập liệu từ Sprint 0–1; script kiểm tra dữ liệu (`/data-plan`); đối chiếu chéo 2 người | data-curator | Mở |
| R-07 | Không kịp nộp LTTTBDD 28/10 (chỉ ~25 ngày, sàn ~50 giờ cho 2 người) | Cao / Cao | Phạm vi chỉ Module A, không AI; bộ câu hỏi nhập xong trước 15/10; tính năng phụ (câu hay sai, thống kê) cắt đầu tiên nếu trễ; đóng băng tính năng 25/10 | project-manager | Mở |
