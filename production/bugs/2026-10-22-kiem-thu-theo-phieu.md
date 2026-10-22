# Kết quả kiểm thử theo phiếu — 22/10/2026

**Người thử**: Kiệt (Claude Code hỗ trợ) · **Bản code**: `dev` @ `ed83ff9` (sau bản sửa review của Tài)
**Phiếu**: `docs/test/phieu-kiem-thu.docx`

## Đã test những gì

| Hạng mục | Kết quả |
|---|---|
| `flutter analyze` | Sạch |
| `flutter test` (bộ test của dự án) | 133 đạt, 0 lỗi, 7 bỏ qua (test chụp màn hình) |
| Test mô phỏng phiếu — `src/app/test/checklist_test.dart` | 10 nhóm đạt, 1 bỏ qua (mục 8) |

`checklist_test.dart` là widget test chạy trên bộ câu hỏi thật, làm theo cột "Làm gì" của phiếu
và kiểm tra theo cột "Kết quả đúng". Nó phủ mục 1–7, 9–31. Chạy: `cd src/app && flutter test test/checklist_test.dart`.

| Mục | Kết quả |
|---|---|
| 1–4 Mở app lần đầu | Đạt (mục 2: xem lỗi phiếu P1) |
| 5–7, 9–10 Học theo chủ đề | Đạt |
| 8 Phóng to hình | Không mô phỏng được (hình không giải mã trong widget test); đã có 2 test riêng trong `question_view_test.dart`, đều đạt |
| 11–12 Ôn câu sai, điểm liệt | Đạt |
| 13–24 Thi thử | Đạt (mục 18: xem lỗi phiếu P2) |
| 25–28 Biển báo, thống kê, đổi hạng | Đạt |
| 29 Chế độ tối | Đạt (chỉ kiểm app chuyển nền tối; độ rõ chữ cần nhìn bằng mắt) |
| 30–31 Ra ngoài 1 phút, tắt app mở lại | Đạt phần logic (mô phỏng đồng hồ); cần thử lại trên Android thật |
| 32 Khóa dọc | Đã kiểm code: `main.dart` khóa portraitUp, `AndroidManifest.xml` có `screenOrientation="portrait"`; cần thử trên máy thật |

## Lỗi cần sửa

### BUG-01 (Low) — Bấm nhanh nhiều câu khi đang lưu, mất lựa chọn ở câu giữa

- **File**: `src/app/lib/features/exam/presentation/exam_screen.dart`, hàm `_select`
- **Mô tả**: Lựa chọn bấm khi lần lưu trước chưa xong được giữ trong `_pending`, nhưng `_pending` chỉ giữ **một** lựa chọn.
- **Tái hiện**: Câu 1 đang lưu (máy chậm) → sang câu 2 chọn đáp án → sang câu 3 chọn đáp án ngay.
  Lựa chọn câu 2 bị ghi đè trong `_pending`, không bao giờ được lưu.
- **Ảnh hưởng**: Không sai điểm (giao diện hiện đúng câu 2 chưa trả lời), nhưng người học có thể không để ý mình chưa làm câu 2.
- **Gợi ý**: giữ hàng đợi theo vị trí (mỗi câu một lựa chọn mới nhất), ví dụ `Map<int, int>`.

### P1 — Phiếu ghi sai điểm đạt hạng A (mục 2)

Phiếu ghi A1 và A đều "đạt từ 21 câu đúng". Đúng là **A1 đạt từ 21/25, A đạt từ 23/25**
(TT 12/2025, Phụ lục II, mục A.I — `docs/data/sources.md`). App hiện đúng 23 cho hạng A.
→ Sửa phiếu, nếu không người thử sẽ đánh mục 2 là Lỗi.

### P2 — Mục 18 thiếu một bước

Sau "Lưu tạm và thoát", app về màn **Thi thử**, chưa về màn chính. Phải bấm Back thêm một lần mới thấy
thẻ "Tiếp tục bài thi". → Sửa phiếu thêm bước này, hoặc cân nhắc cho màn Thi thử hiện bài đang dở.

### P3 — Mục 5 (chỉ là cách ghi)

App hiện "Tất cả câu hỏi" và "250 câu" thành hai dòng riêng, không phải "Tất cả câu hỏi (250)". Không phải lỗi app;
nên sửa câu chữ trong phiếu cho khớp.

## Các lỗi review trước (22/10)

1 High, 1 Medium, 6 Low đã được sửa đúng trong `ed83ff9`.
