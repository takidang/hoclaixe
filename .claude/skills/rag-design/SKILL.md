---
name: rag-design
description: "Phase 3 — thiết kế hệ thống RAG + Gemini cho chatbot giải thích luật/đáp án và tính năng AI cá nhân hóa."
---

Chủ trì: ai-engineer. Review: technical-director, data-curator, security-reviewer.

1. Đọc SRS (Module B), `docs/data/sources.md`, kiến trúc.
2. Dùng WebSearch kiểm tra: model Gemini và model embedding hiện có, giới hạn gói miễn phí, SDK cho backend đã chọn.
3. Viết `docs/ai/rag-design.md` theo `docs/templates/rag-design-template.md`:
   - Kho tri thức: văn bản luật (chunk theo điều/khoản), bộ câu hỏi + giải thích, biển báo. Metadata đầy đủ.
   - Indexing: chunk size, overlap, embedding model, vector store, cách cập nhật khi luật đổi.
   - Retrieval: top-k, ngưỡng, có rerank không, lọc theo hạng bằng.
   - Generation: system prompt (chỉ dùng ngữ cảnh, bắt buộc trích dẫn, từ chối khi ngoài phạm vi), định dạng output.
   - Chống lỗi: hết quota, timeout, cache, fallback.
   - Sơ đồ sequence Mermaid cho một lượt hỏi.
4. Nếu có tính năng cá nhân hóa: mô tả input (lịch sử làm bài), thuật toán, output; nói rõ phần nào dùng LLM.
5. Đề xuất bộ đánh giá ban đầu cho `/ai-eval`. Hỏi trước khi ghi.
