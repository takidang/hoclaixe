# Các phase

| # | Phase | Skill chính | Đầu ra | Gate |
|---|---|---|---|---|
| 0 | Khởi động | /start | project-context.md điền đủ | — |
| 1 | Discovery | /discovery | docs/srs/vision.md (vấn đề, người dùng, đối thủ, phạm vi MVP) | Phạm vi Module A/B/C đã chốt |
| 2 | Yêu cầu | /write-srs | docs/srs/SRS.md, use case, user story có acceptance criteria | Mọi tính năng MVP có AC kiểm thử được |
| 3 | Thiết kế | /ux-design, /create-architecture, /adr, /data-plan, /rag-design, /vision-design, /dataset-plan | UX spec, kiến trúc, ERD, ADR, kế hoạch dữ liệu, thiết kế RAG, vision-design.md, dataset-plan.md, danh mục biển báo | Kiến trúc review xong, dữ liệu có nguồn chính thức |
| 4 | Chuẩn bị | /setup-flutter, /create-stories, /sprint-plan | Project Flutter chạy được, backlog, sprint 1 | `flutter analyze` sạch, test mẫu chạy |
| 5 | Phát triển | /dev-story, /code-review, /story-done, /sprint-plan, /retro, /ml-train | Code + test theo từng story | Mỗi sprint có demo chạy được |
| 6 | Kiểm thử | /test-plan, /ai-eval, /ml-eval, /bug-report | Test plan, bảng test case, kết quả đánh giá RAG, kết quả đánh giá nhận diện | Không còn bug Critical/High; AI eval đạt ngưỡng; ML eval đạt ngưỡng đã chốt trong vision-design |
| 7 | Phát hành | /release-checklist, /web-port (tùy chọn) | APK/AAB, (web build), release notes | Checklist PASS |
| 8 | Báo cáo & bảo vệ | /write-report, /defense-prep | Báo cáo từng đồ án, slide, bộ câu hỏi phản biện | Báo cáo đủ chương, số liệu khớp code |

Có thể làm song song: viết báo cáo (phase 8) nên bắt đầu từ sprint 2, mỗi sprint viết thêm một phần.
Lệnh `/status` cho biết đang ở phase nào và việc tiếp theo.
