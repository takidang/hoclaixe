---
name: story-done
description: "Đóng một story: xác nhận AC, test xanh, cập nhật backlog/sprint/status, ghi chú cho báo cáo."
argument-hint: "<ST-xx>"
---

1. Kiểm tra: mọi AC của $ARGUMENTS đều PASS, `flutter analyze` sạch, `flutter test` xanh, code-review không còn Must fix.
2. Thiếu điều gì → liệt kê và không đóng.
3. Đủ → cập nhật trạng thái trong story, sprint, backlog (hỏi trước).
4. Thêm một dòng vào `docs/reports/dev-log.md`: ngày, story, người làm, tóm tắt, ảnh chụp màn hình cần chụp (`[CẦN ẢNH: ...]`).
   File này là nguyên liệu cho chương "Cài đặt/Hiện thực" của báo cáo.
