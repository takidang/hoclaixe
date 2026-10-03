---
name: defense-prep
description: "Chuẩn bị bảo vệ: dàn ý slide, kịch bản demo, bộ câu hỏi phản biện và gợi ý trả lời, phân công trình bày."
argument-hint: "<ltttbdd | chuyen-nganh>"
---

Chủ trì: report-writer. Hỗ trợ: technical-director, ai-engineer, product-director.

1. Dàn ý slide 12–18 trang: vấn đề → giải pháp → kiến trúc → AI/RAG (với chuyên ngành) → demo → kết quả đo → hạn chế → hướng phát triển.
2. Kịch bản demo 5–7 phút, từng bước, kèm phương án dự phòng (mất mạng, hết quota → video).
   Có phần demo nhận diện biển báo (chuẩn bị ảnh biển in sẵn để chụp khi demo trong phòng).
3. 25–30 câu hỏi phản biện hội đồng có thể hỏi (kỹ thuật, AI, quy trình, dữ liệu, bảo mật, đóng góp từng người) + gợi ý trả lời dựa trên tài liệu thật.
   Ví dụ: "Vì sao dùng RAG mà không fine-tune?", "Làm sao biết chatbot trả lời đúng?", "Luật thay đổi thì cập nhật thế nào?",
   "Vì sao phân loại mà không phát hiện?", "Ảnh không phải biển báo thì sao?", "Model đúng bao nhiêu % trên ảnh thật?",
   "Vì sao vẫn cần Gemini khi đã có model?", "Làm sao đảm bảo app không hiển thị ý nghĩa biển sai?".
4. Phân công phần trình bày cho 2 thành viên.
Ghi `docs/reports/defense-<báo cáo>.md` (hỏi trước). Nếu cần file .pptx, nhắc người dùng tạo bằng công cụ trình chiếu từ dàn ý này.
