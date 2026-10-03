---
paths:
  - "ml/**"
  - "src/app/lib/features/sign_recognition/**"
---

# Quy tắc ML & nhận diện biển báo

- Model chỉ xuất mã biển hoặc lớp "không phải biển báo". Nội dung hiển thị luôn tra từ `data/sign-catalog/`.
- `labels.txt` phải khớp 1-1 với mã trong danh mục; có test kiểm tra điều này.
- Tiền xử lý ảnh trong app (resize, chuẩn hóa) phải giống hệt lúc huấn luyện — ghi thông số trong MODEL_CARD và dùng chung hằng số.
- Suy luận chạy ngoài UI thread (isolate/background); có timeout.
- Áp dụng ngưỡng độ tin cậy từ cấu hình, không hardcode rải rác.
- Code dùng plugin TFLite phải đặt sau interface `SignRecognizer`; bản web dùng `GeminiSignRecognizer` (conditional import).
- Kết quả Gemini vision: backend kiểm tra mã hợp lệ; mã lạ → coi là `UNKNOWN`.
- Không commit dataset ảnh và checkpoint lớn; chỉ commit model phát hành + MODEL_CARD.
- Ảnh người dùng chụp không gửi lên server khi dùng on-device; khi rơi về Gemini phải có thông báo cho người dùng. Không lưu ảnh người dùng trên server.
- Notebook phải chạy lại được từ đầu (seed cố định, ghi phiên bản thư viện).
