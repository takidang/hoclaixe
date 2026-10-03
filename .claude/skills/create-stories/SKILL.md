---
name: create-stories
description: "Phase 4 — tách SRS thành epic và user story có acceptance criteria, story point, phân module."
---

Chủ trì: project-manager. Hỗ trợ: business-analyst.

1. Đọc SRS, UX spec, architecture.
2. Đề xuất danh sách epic (theo tính năng lớn) và story. Mỗi story theo `docs/templates/story-template.md`:
   mã (ST-xx), FR liên quan, module, mô tả, acceptance criteria Given/When/Then, story point, phụ thuộc, người phụ trách đề xuất.
3. Story > 8 point → tách. Story kỹ thuật (setup, CI, data import) cũng là story.
4. Trình bày bảng tổng hợp, chờ duyệt, rồi ghi `production/backlog.md` và từng file `production/stories/ST-xx.md`.
5. Nếu team dùng Jira/Trello: xuất thêm bảng CSV để import (hỏi trước).
