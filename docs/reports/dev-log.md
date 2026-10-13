# Nhật ký phát triển (nguyên liệu chương Cài đặt / Hiện thực của báo cáo)

| Ngày | Story | Người làm | Tóm tắt | Ảnh cần chụp |
|---|---|---|---|---|
| 13/10/2026 | Setup | Tài (Claude Code) | Tạo project Flutter `src/app` (Riverpod, sqflite, go_router); đồng bộ 600 câu + 397 biển vào assets kèm mã băm; DB SQLite 6 bảng; tắt backup Android, khóa dọc | [CẦN ẢNH: màn "Đã nạp 600 câu hỏi · 397 biển báo" trên emulator] [CẦN ẢNH: sơ đồ kiến trúc + ERD từ architecture.md] |
| 13/10/2026 | ST-01 | Tài (Claude Code) | Lõi thi thử thuần Dart: sinh đề theo cấu trúc CV 2262 (1 câu điểm liệt theo hạng + nhóm chương, không trùng, xáo trong nhóm), 20 đề cố định bằng seed FNV-1a + mulberry32 (ổn định qua phiên bản SDK, an toàn web), chấm điểm 2 điều kiện (đủ điểm và đúng câu điểm liệt), chọn cấu trúc theo ngày hiệu lực. Test: 3.000 đề trên dữ liệu thật, bảng 18 ca chấm | [CẦN ẢNH: kết quả `flutter test` 37 test xanh] [CẦN ẢNH: đoạn code ExamGenerator.generate] |
