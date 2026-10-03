---
paths:
  - "src/backend/**"
  - "src/app/lib/features/assistant/**"
---

# Quy tắc backend & AI

- API key chỉ đọc từ biến môi trường / secret manager. Không log key.
- System prompt nằm phía server; client chỉ gửi câu hỏi người dùng và bối cảnh tối thiểu (hạng bằng).
- Giới hạn độ dài input; rate limit theo người dùng.
- Trả lời phải kèm danh sách nguồn (văn bản, điều, khoản) lấy từ metadata truy xuất — không để model tự bịa nguồn.
- Không đủ ngữ cảnh liên quan (dưới ngưỡng tương đồng) → trả lời "không tìm thấy căn cứ" thay vì gọi model đoán.
- Xử lý lỗi Gemini (quota, timeout, nội dung bị chặn) → mã lỗi rõ ràng cho app.
- Thay đổi prompt, chunking, top-k → chạy lại `/ai-eval run` và ghi kết quả.
