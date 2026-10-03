---
paths:
  - "src/app/test/**"
  - "src/app/integration_test/**"
---

# Quy tắc test

- Cấu trúc thư mục test giống `lib/`. Tên file `<tên>_test.dart`.
- Mỗi test theo Arrange – Act – Assert, tên test mô tả hành vi: `'trượt khi sai câu điểm liệt dù đủ điểm'`.
- Logic nghiệp vụ (chấm điểm, sinh đề, đếm giờ, thống kê chủ đề yếu) bắt buộc có unit test, gồm cả trường hợp biên.
- Không gọi mạng thật hay Gemini thật trong unit/widget test: dùng fake/mock.
- Test không phụ thuộc thứ tự chạy, không phụ thuộc thời gian thật (inject clock).
- Mỗi test case trong `docs/test/test-cases.md` có test tự động → ghi tên test tương ứng.
