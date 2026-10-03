# Điều phối agent

## Ba tầng

- **Tầng 1 — Định hướng**: `product-director` (tầm nhìn, phạm vi), `technical-director` (kiến trúc, công nghệ), `project-manager` (tiến độ, rủi ro, sprint).
- **Tầng 2 — Trưởng mảng**: `business-analyst`, `ux-designer`, `ai-engineer`, `ml-engineer`, `qa-engineer`, `report-writer`.
- **Tầng 3 — Thực thi**: `flutter-developer`, `backend-developer`, `data-curator`, `security-reviewer`, `release-engineer`.

## Quy tắc

1. Agent chỉ làm trong mảng của mình; việc ngoài mảng → đề xuất chuyển cho agent phù hợp.
2. Xung đột phạm vi → `product-director`. Xung đột kỹ thuật → `technical-director`. Xung đột lịch → `project-manager`. Người dùng quyết cuối cùng.
3. Thay đổi yêu cầu sau khi SRS đã chốt → `business-analyst` cập nhật SRS + `project-manager` đánh giá ảnh hưởng tiến độ.
4. Mọi thay đổi kiến trúc quan trọng → ghi ADR trong `docs/architecture/adr/`.
5. Mọi dữ liệu luật/câu hỏi → qua `data-curator`, có nguồn và ngày hiệu lực.
6. Không tự ý mở rộng phạm vi. Ý tưởng hay ngoài phạm vi → ghi vào `production/ideas.md`.

## Ai làm gì trong mỗi skill

| Skill | Agent chủ trì | Agent review |
|---|---|---|
| /discovery | product-director | business-analyst, project-manager |
| /write-srs | business-analyst | product-director, qa-engineer |
| /ux-design | ux-designer | product-director, flutter-developer |
| /create-architecture, /adr | technical-director | flutter-developer, backend-developer, security-reviewer |
| /data-plan | data-curator | business-analyst |
| /rag-design, /ai-eval | ai-engineer | technical-director, data-curator |
| /vision-design, /dataset-plan, /ml-train, /ml-eval | ml-engineer | technical-director, data-curator, ux-designer |
| /create-stories, /sprint-plan, /retro | project-manager | business-analyst |
| /dev-story | flutter-developer hoặc backend-developer | — |
| /code-review | technical-director | security-reviewer |
| /test-plan, /bug-report | qa-engineer | business-analyst |
| /release-checklist, /web-port | release-engineer | qa-engineer, security-reviewer |
| /write-report, /defense-prep | report-writer | product-director, technical-director |
