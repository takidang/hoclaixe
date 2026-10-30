# Thiết kế giao diện v1 — "Vạch kẻ đường"

> Chốt 30/10/2026 (Tài chọn hướng "Vạch kẻ đường", phạm vi: màn chính + học + thi).
> Thay design system v0 (21/10). Token nằm một chỗ: `src/app/lib/core/theme/app_theme.dart`.

## Ý tưởng chủ đạo

**Mỗi câu học chắc là một đoạn vạch được sơn liền.** Người học đi trên một làn đường:
lúc đầu vạch là nét đứt (như vạch 3.3), học tới đâu vạch liền tới đó (như vạch 3.2).
Màu, chữ, chuyển động đều lấy từ mặt đường và biển chỉ dẫn. Thứ gì không phục vụ ý này thì bỏ.

## Bảng màu (token)

| Token | Sáng | Tối | Dùng cho |
|---|---|---|---|
| canvas | `#F2F4F6` | `#0F1419` | Nền màn hình (xám pha tông nhựa đường, không trắng thuần) |
| panel | `#FBFCFD` | `#171E25` | Thẻ, danh sách |
| accent | `#0B4F8C` | `#8CBCEB` | Xanh biển chỉ dẫn: nút chính, focus, vạch đã sơn ngoài mặt đường |
| accent-muted | `#D3E4F8` | `#1E3A57` | Nền nhẹ của icon, rãnh thanh tiến độ |
| text-primary | `#141B22` | `#E7ECF0` | Chữ chính |
| text-secondary | `#535E69` | `#A4AFBA` | Chữ phụ |
| asphalt | `#2A3139` | `#232B33` | Mặt đường của thẻ tiến độ (signature) |
| marking | `#F1F3F5` | `#E9EDF0` | Vạch sơn trắng trên mặt đường |

Đúng/sai giữ `AnswerColors` (xanh lá / đỏ), không dùng cho trang trí.

## Chữ (type trio)

- **Display**: Be Vietnam Pro Bold 700: tiêu đề, số lớn.
- **Body**: Be Vietnam Pro Regular 400 / Medium 500 / SemiBold 600: nội dung câu hỏi, đáp án.
- **Mono**: JetBrains Mono Medium 500 (OFL): chỉ cho **số đứng riêng**: số lớn của tiến độ và điểm, đồng hồ, số trên phím đáp án, số gốc trong kết quả tìm kiếm. Không dùng cho cụm chữ tiếng Việt (khoảng cách chữ mono quá thưa).

## Chuyển động

- `AppMotion.quick` 200 ms `easeOutCubic`: đổi trạng thái, chuyển câu.
- `AppMotion.paint` 700 ms `Cubic(0.2, 0, 0, 1)`: vạch được "sơn" thêm.
- Màn chính: các khối hiện lần lượt, lệch 80 ms.
- Máy bật "giảm chuyển động" (`disableAnimations`) thì hiện ngay trạng thái cuối.

## Signature element: `LaneLine`

Một làn vạch kẻ ngang. Hai kiểu:
- **Tiến độ** (màn chính, màn học, màn thi): phần đã xong là vạch liền, phần còn lại là nét đứt 1:1.
- **Từng câu** (kết quả thi): mỗi câu một đoạn; đúng = đoạn liền, sai = đoạn đỏ, chưa trả lời = đoạn mờ.

Trên màn chính nó nằm trên mặt đường tối (asphalt). Đây là chỗ duy nhất "táo bạo", phần còn lại yên tĩnh.

**Tương tác có thiết kế**: trả lời đúng một câu thì vạch phía trên câu hỏi được sơn thêm một đoạn
(700 ms, chạy từ trái sang). Quay lại màn chính, vạch trên mặt đường sơn tiếp từ chỗ cũ, không nhảy từ 0.

## Màn hình và chữ trên giao diện

### 1. Màn chính
- Thanh trên: `Hạng A1` · nút `Đổi hạng` · biểu tượng `Tìm câu hỏi` · biểu tượng `Giới thiệu`.
- (Nếu có) thẻ `Tiếp tục bài thi` · `Còn 12:34`.
- **Thẻ mặt đường**: nhãn `Tiến độ ôn tập` · số lớn `142` + `/ 250 câu` · LaneLine ·
  chú thích `Mỗi câu đúng ở lần làm gần nhất sơn liền một đoạn vạch.`
- **Nút chính** (CTA duy nhất của màn): `Thi thử` · dòng phụ `Hạng A1 · 25 câu · 19 phút` (điểm đạt xem ở màn thông tin đề).
- Nhãn mục `Ôn luyện`, danh sách 6 dòng (cùng kiểu: icon vuông bo góc + tên + dòng phụ):
  - `Học theo chủ đề` · `Từng chương của bộ câu hỏi`
  - `Câu điểm liệt` · `20 câu · sai một câu là trượt` (icon vàng: `tertiaryContainer`, màu biển cảnh báo)
  - `Ôn câu sai` · `12 câu đang chờ ôn`
  - `Câu đã lưu` · `3 câu`
  - `Biển báo` · `Danh mục theo QCVN 41:2024`
  - `Thống kê` · `Lần thi, tỉ lệ đạt, câu hay sai`

### 2. Màn học (một câu hỏi)
- Thanh trên: tên chủ đề · `Đọc câu hỏi` / `Dừng đọc` · `Lưu câu` / `Bỏ lưu` · `Làm lại`.
- LaneLine mảnh ngay dưới thanh trên: số câu đã trả lời trong lượt này.
- Đầu câu: `Câu 12` (xanh) · nhãn `Điểm liệt` (nếu có) · `Số gốc 123` (nhỏ).
- Đáp án: ô số `1` `2` `3` `4` (mono) + nội dung; đúng/sai hiện ngay sau khi chọn.
- Thanh dưới: `‹` · `Câu 12 / 25` · `›`.
- Thông báo: `Đã lưu câu này` · `Đã bỏ lưu` · `Máy chưa có giọng đọc tiếng Việt. Cài giọng tiếng Việt trong Cài đặt > Chuyển văn bản thành giọng nói.`
- Trống: `Bạn chưa lưu câu nào` · `Bấm biểu tượng dấu trang khi học để lưu câu muốn xem lại.`

### 3. Màn thi và kết quả
- Màn thi: đồng hồ `18:42` (mono) · `Đã làm 6/25` · LaneLine tiến độ số câu đã làm.
- Kết quả: `ĐẠT` / `KHÔNG ĐẠT` · điểm `23` (mono, lớn) `/ 25 câu đúng` · LaneLine từng câu ·
  chú thích `Mỗi đoạn là một câu: liền là đúng, đỏ là sai, mờ là chưa trả lời.`

### 4. Tìm câu hỏi
- Ô tìm: `Số câu hoặc từ khóa, gõ không dấu cũng được`
- Chưa gõ: `Ví dụ: 120, nồng độ cồn, nhường đường`
- Kết quả: `8 câu` · mỗi dòng số gốc (mono) + 3 dòng đầu câu hỏi.
- Không có: `Không tìm thấy câu nào.`

Các màn còn lại (danh sách đề, biển báo, thống kê, giới thiệu) tự nhận màu/chữ mới qua theme, không đổi bố cục.
