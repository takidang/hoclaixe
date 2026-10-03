---
name: ai-eval
description: "Đánh giá định lượng chatbot RAG: độ chính xác, trích dẫn đúng, từ chối đúng, thời gian phản hồi."
argument-hint: "[build-set | run | report]"
---

Chủ trì: ai-engineer. Chế độ: $ARGUMENTS (mặc định `build-set`).

- `build-set`: cùng người dùng xây `docs/ai/eval-set.md` (hoặc JSON trong `data/eval/`): khoảng 50–100 câu hỏi gồm
  câu về luật, câu giải thích đáp án, câu ngoài phạm vi, câu gài (prompt injection). Mỗi câu có đáp án chuẩn và điều luật nguồn —
  người dùng xác nhận đáp án chuẩn, không để AI tự chấm đáp án chuẩn.
- `run`: viết/chạy script gọi endpoint chatbot cho từng câu, lưu kết quả (câu trả lời, nguồn trích dẫn, thời gian).
  Lưu ý quota gói miễn phí: chạy theo lô, có delay.
- `report`: `docs/ai/eval-report.md` — tỷ lệ đúng, tỷ lệ trích dẫn đúng điều luật, tỷ lệ từ chối đúng, thời gian trung bình/p95,
  so sánh có RAG và không RAG (nếu chạy được) — đây là bằng chứng mạnh nhất cho phần AI khi bảo vệ. Phân tích lỗi điển hình.
