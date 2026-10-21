# Ôn bảo vệ — phần của Tài: Màn thi thử

> Tóm tắt 1 câu: **màn làm bài thi có đồng hồ đếm ngược; đáp án được lưu xuống SQLite ngay khi chạm; hết giờ tự nộp;
> thoát ra hay tắt app vẫn quay lại làm tiếp được.**

File chính: [`exam_screen.dart`](../../src/app/lib/features/exam/presentation/exam_screen.dart)
(ngoài ra: [`exam_session.dart`](../../src/app/lib/features/exam/domain/exam_session.dart),
[`exam_session_repository.dart`](../../src/app/lib/features/exam/data/exam_session_repository.dart),
[`exam_exit_sheet.dart`](../../src/app/lib/features/exam/presentation/exam_exit_sheet.dart))

## 1. Luồng màn hình

```
Thi thử → chọn đề → Thông tin đề → [Bắt đầu]
   → Màn thi: đồng hồ ⏱ · dải số câu · câu hỏi · [◀ Nộp bài ▶]
        chạm đáp án  → lưu SQLite → tô đáp án
        đồng hồ 00:00 → tự nộp
        Nộp / nút Back → bảng 4 lựa chọn
   → Kết quả → Xem lại bài
```

## 2. Năm điểm kỹ thuật cần nói được (mở file, chỉ đúng dòng)

| # | Ý chính | Ở đâu | Kiến thức Flutter/Dart |
|---|---|---|---|
| 1 | Màn thi là **StatefulWidget** vì có trạng thái thay đổi: câu đang xem, đáp án, thời gian còn lại | `_ExamBodyState` dòng 49 | `StatefulWidget`, `setState` |
| 2 | **Đồng hồ**: `initState` tạo `Timer.periodic` 1 giây/lần; `dispose` hủy timer | dòng 64–84 | vòng đời widget, `Timer` (`dart:async`) |
| 3 | **Giờ tính theo hạn tuyệt đối**: lúc bắt đầu lưu `deadline = giờ bắt đầu + 19 phút` vào DB; mỗi giây tính `còn lại = deadline − giờ hiện tại` | `remaining()` trong `exam_session.dart` dòng 31; repository dòng 32 | `DateTime`, `Duration` |
| 4 | **Lưu đáp án trước rồi mới vẽ lại**: `await repo.saveAnswer(...)` xong mới `setState` | `_select` dòng 102–108 | `async/await`, `Future` |
| 5 | **Chặn nút Back**: `PopScope(canPop: false)` → mở bảng *Nộp bài / Lưu tạm và thoát / Không lưu và thoát / Tiếp tục* | dòng 197–200, `exam_exit_sheet.dart` | `PopScope`, `showModalBottomSheet` |

Thêm khi còn thời gian: đồng hồ đổi **vàng** khi < 2 phút, **đỏ** khi < 60 giây (dòng 189); dải số câu tự cuộn giữ
câu đang xem ở giữa (`_centre`, dòng 335); hết giờ khi đang mở bảng Nộp bài → đóng bảng rồi nộp (`_timeUp`, dòng 92).

## 3. Câu thầy có thể hỏi — gợi ý trả lời

1. **Vì sao dùng `StatefulWidget` mà không phải `StatelessWidget`?**
   Màn này có dữ liệu thay đổi theo thời gian (giây còn lại, câu đang xem, đáp án đã chọn). Khi đổi, gọi `setState` để Flutter vẽ lại.
2. **Vì sao `Timer.periodic` mà không `Future.delayed`?** `Future.delayed` chạy một lần; cần cập nhật mỗi giây nên dùng
   timer lặp. Phải `cancel()` trong `dispose()`, không thì timer vẫn chạy khi đã rời màn (rò rỉ, lỗi `setState` sau khi dispose).
3. **Tắt app giữa bài thì sao? Giờ có chạy tiếp không?** Có. Đồng hồ không đếm lùi một biến trong RAM mà so giờ hiện
   tại với **hạn nộp đã lưu trong SQLite**. Mở lại app → hỏi "Tiếp tục bài thi?"; nếu đã quá giờ → tự nộp và hiện kết quả.
4. **Vì sao lưu đáp án trước rồi mới đổi giao diện?** Để giao diện không bao giờ hiện một đáp án chưa được lưu. App đối thủ
   bị phàn nàn "đáp án tự đổi khi nộp" — app mình chấm điểm từ chính đáp án đọc lại trong DB nên kết quả khớp 100%.
5. **`async/await` là gì?** Ghi DB tốn thời gian; `await` chờ ghi xong mà không chặn giao diện (UI vẫn mượt).
6. **Bấm Nộp bài 2 lần có ra 2 kết quả không?** Không. Lệnh cập nhật chỉ chạy khi bài đang ở trạng thái "đang làm"
   (`WHERE status = 'in_progress'`); lần 2 không đổi dòng nào nên bị bỏ qua. Màn hình cũng có cờ `_submitting`.
7. **`mounted` để làm gì?** Sau một `await`, màn có thể đã bị đóng; kiểm `mounted` trước khi `setState` / chuyển màn để không lỗi.
8. **Câu điểm liệt khi đang thi có hiện nhãn không?** Không (giống phần mềm sát hạch thật); chỉ hiện ở Kết quả và Xem lại.
   Cùng một widget `QuestionView`, chỉ khác tham số `mode`.
9. **Kiểm thử thế nào?** Widget test giả lập đồng hồ: tua tới còn 30 giây → kiểm đồng hồ; tua tới 00:00 → kiểm tự nộp và
   trạng thái trong DB là "đã nộp". Chạy `flutter test`.

## 4. Demo 1–2 phút

1. Màn chính → **Thi thử** → **Đề số 1** → chỉ thông tin đề (25 câu · 19 phút · 1 câu điểm liệt) → **Bắt đầu**.
2. Chọn đáp án câu 1, đổi sang đáp án khác → chạm số **7** trên dải số câu → quay lại câu 1: đáp án vẫn còn.
3. Bấm nút **Back** → bảng 4 lựa chọn → **Lưu tạm và thoát** → màn chính có thẻ **"Tiếp tục bài thi"** → bấm vào: bài còn nguyên.
4. **Nộp bài** → **Nộp bài và chấm điểm** → Kết quả (ĐẠT/KHÔNG ĐẠT + lý do) → **Xem lại bài** → bật **"Chỉ câu sai"**.
