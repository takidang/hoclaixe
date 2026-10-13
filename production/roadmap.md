# Roadmap (chỉnh trong /sprint-plan)

> **Đổi phạm vi 13/10/2026**: đồ án chuyên ngành đã đổi sang đề tài khác — hoclaixe **chỉ còn là đồ án LTTTBDD**.
> Ưu tiên duy nhất: **Module A làm giống app đối thủ, xong trước 28/10/2026**. Module B (chatbot), D (nhận diện biển),
> C (web) chuyển thành "làm sau nếu còn thời gian" — tài liệu, agent, skill phần AI giữ lại, không xóa.

## Sprint 1 — 12/10–28/10/2026: Module A (nộp LTTTBDD)

| Ngày | Việc | Kết quả |
|---|---|---|
| 13–14/10 | Sửa dữ liệu (26 câu thiếu hình) · `/create-architecture` gọn · `/setup-flutter` · nạp 600 câu + 397 biển vào app | App chạy, có dữ liệu |
| 15–18/10 | Chọn hạng · màn chính · học theo chủ đề (Đúng/Sai/Chưa làm) · hiển thị câu + hình | Học được |
| 19–22/10 | Thi thử: đề ngẫu nhiên + 20 đề cố định · đồng hồ · lưới câu · lưu đáp án · chấm điểm + điểm liệt · kết quả, xem lại | Thi được |
| 23–25/10 | Ôn câu sai · câu điểm liệt · danh mục biển báo · miễn trừ · (thống kê nếu kịp) · **đóng băng tính năng 25/10** | Đủ Must |
| 26–28/10 | Test (giữ đáp án, chấm điểm) · build APK · báo cáo LTTTBDD | Nộp |

UX: bố cục theo ảnh đối thủ (`design/reference/competitors/`); giao diện đẹp làm bằng Claude Design song song.
Lùi khi trễ (theo thứ tự cắt): thống kê, câu hay sai, tìm kiếm, chế độ tối, chấm ngay khi chọn, đánh dấu câu.

## Sau 28/10 (nếu còn thời gian)
Tra cứu luật · chatbot RAG (Module B) · nhận diện biển báo bằng Gemini vision (Module D) · Flutter Web (Module C).
