# Claude Code App Studio — Flutter + AI

Một "công ty làm app" ảo chạy trong Claude Code: mỗi agent là một vai trò,
mỗi skill (slash command) là một bước quy trình. Người dùng (team 2 sinh viên)
là chủ dự án và ra mọi quyết định cuối cùng.

## Bối cảnh dự án

@.claude/docs/project-context.md

## Ngôn ngữ

- Trao đổi với người dùng và viết tài liệu/báo cáo: **tiếng Việt**.
- Code, tên biến, commit message, tên file: **tiếng Anh**.
- Thuật ngữ chuyên ngành giữ tiếng Anh khi cần, kèm giải thích lần đầu (ví dụ: RAG — Retrieval-Augmented Generation).

## Quy trình theo phase

@.claude/docs/phases.md

Mỗi phase kết thúc bằng `/gate-check`. Không nhảy phase khi gate chưa PASS,
trừ khi người dùng nói rõ "bỏ qua gate".

## Giao thức cộng tác (bắt buộc)

Mọi việc đi theo: **Hỏi → Đưa phương án → Người dùng chọn → Viết nháp → Duyệt → Ghi file**

- Hỏi "Tôi ghi vào `<đường dẫn>` được không?" trước khi tạo/sửa file. Nhiều file → xin duyệt cả bộ một lần.
- Không commit, không push khi người dùng chưa yêu cầu.
- Không bịa dữ liệu: câu hỏi thi, điều luật, mức phạt phải có nguồn chính thức. Không chắc → nói không chắc.
- AI không bao giờ là nguồn sự thật: chatbot phải trích dẫn nguồn; nhận diện biển báo chỉ chọn mã, nội dung lấy từ danh mục chuẩn.
- Phát hiện yêu cầu mơ hồ hoặc mâu thuẫn → nêu ra, không tự đoán.
- Cuối mỗi phiên làm việc: cập nhật `production/status.md` (phase hiện tại, việc đã xong, việc tiếp theo, blocker).

## Điều phối agent

@.claude/docs/coordination.md

## Bảo mật

- API key (Gemini, Firebase admin…) KHÔNG bao giờ nằm trong code Flutter hay trong git.
  App gọi AI qua backend/proxy (Cloud Functions hoặc server riêng); key nằm trong biến môi trường.
- `.env`, `*.jks`, `key.properties`, service account JSON luôn nằm trong `.gitignore`.
- Ảnh người dùng không lưu trên server; dataset ảnh huấn luyện không commit lên git.

> **Phiên đầu tiên?** Chạy `/start`.
