---
paths:
  - "data/**"
  - "src/app/assets/data/**"
---

# Quy tắc dữ liệu

- Mọi file dữ liệu có nguồn ghi trong `docs/data/sources.md` (văn bản, số hiệu, ngày hiệu lực, ngày truy cập).
- Không thêm, sửa câu hỏi thi hay nội dung luật dựa trên trí nhớ của AI. Chỉ chép/chuyển đổi từ nguồn chính thức.
- Mỗi câu hỏi: id duy nhất, đúng một đáp án đúng, có chủ đề, cờ điểm liệt, danh sách hạng bằng áp dụng, ảnh (nếu có) tồn tại.
- Sau khi sửa dữ liệu: chạy script kiểm tra dữ liệu trong `tools/validate_data`.
- Thay đổi phiên bản bộ đề/luật → ghi rõ trong sources.md và CHANGELOG.
