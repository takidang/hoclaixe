# Thiết kế giao diện v2 — thẻ gradient + vạch kẻ đường

> Chốt 30/10/2026: Tài gửi mẫu tham khảo (app học tập nền tối, thẻ gradient, thanh tab nổi) và chọn
> "phong cách mới + giữ vạch", thanh 4 tab, biểu đồ đặt ở tab Thống kê.
> Thay v1 "Vạch kẻ đường" (cùng ngày) và design system v0 (21/10). Token nằm một chỗ:
> `src/app/lib/core/theme/app_theme.dart`.

## Ý tưởng chủ đạo

**Mỗi câu học chắc là một đoạn vạch được sơn liền** (giữ từ v1): lúc đầu vạch là nét đứt (như vạch 3.3),
học tới đâu vạch liền tới đó (như vạch 3.2). v2 đặt vạch đó lên các **thẻ gradient pastel** trên nền tối,
mỗi thẻ có **một biển báo thật** từ danh mục QCVN 41:2024 làm hình minh họa.

Khác mẫu tham khảo, có chủ ý:
- Hình 3D (DNA, hành tinh, sách) là tài sản của người thiết kế mẫu → thay bằng hình biển báo thật trong app.
- Helvetica có bản quyền và thiếu dấu tiếng Việt → giữ Be Vietnam Pro (dáng chữ gần giống).
- Biểu đồ "Time Spent" tính giờ → app không đo thời gian, nên vẽ **số câu đã làm mỗi ngày** (số liệu thật).
- Thanh tiến độ trơn → vạch nét đứt được sơn liền (dấu ấn riêng của app).

## Bảng màu (token)

| Token | Sáng | Tối | Dùng cho |
|---|---|---|---|
| canvas (`surface`) | `#F2F3F5` | `#1B1D1F` | Nền màn hình (không trắng/đen thuần) |
| panel (`surfaceContainerLowest`) | `#FCFCFD` | `#26292D` | Thẻ thường, danh sách, biểu đồ |
| accent (`primary`) | `#0B4F8C` | `#7CC4FA` | Nút chính, focus, cột "Thi thử" |
| accent 2 (`secondary`) | `#B83A86` | `#F786D0` | Cột "Học", chuỗi ngày học |
| text-primary | `#15171A` | `#F4F5F6` | Chữ chính |
| text-secondary | `#565C64` | `#A5ABB3` | Chữ phụ |
| tab bar (`inverseSurface`) | `#1B1D1F` | `#F4F5F6` | Viên thuốc chứa 4 tab (ngược màu nền) |
| `ink` / `inkSoft` | `#15171A` / 85 % | như sáng | Chữ và vạch trên thẻ gradient (đo ≥ 4,9:1 ở đầu tối nhất) |

Gradient thẻ (`AppGradients`, giống nhau ở cả hai chế độ, chéo từ trên trái xuống dưới phải):

| Tên | Màu | Dùng cho |
|---|---|---|
| sunset | `#FFD27A → #F7708F` | Tiến độ ôn tập |
| sky | `#9AD8FF → #8B8CF6` | Thi thử |
| amber | `#FFE38A → #FF9A5C` | Câu điểm liệt (màu biển cảnh báo) |
| bloom | `#FBC2E6 → #E07BEF` | Ôn câu sai, Ôn các câu đã lưu |
| leaf | `#CFF5A0 → #4FD1C5` | Biển báo |

Thẻ chủ đề ở tab Học lần lượt dùng sky → bloom → leaf → sunset → amber. Đúng/sai giữ `AnswerColors`.
**Mặc định nền tối**; người dùng đổi Sáng / Tối / Theo máy ở màn Giới thiệu.

## Chữ

- **Display**: Be Vietnam Pro Bold 700: tiêu đề màn (`Hạng A1`), tiêu đề thẻ.
- **Body**: Be Vietnam Pro 400 / 500 / 600.
- **Mono**: JetBrains Mono Medium 500 (OFL): chỉ cho số đứng riêng (số lớn của tiến độ và điểm, đồng hồ,
  phím đáp án, số gốc, tổng số câu của biểu đồ). Không dùng cho cụm chữ tiếng Việt.
- Chữ trong thẻ gradient lấy từ `AppTheme.cardText(context)` (ép màu `ink`; kiểu chữ của theme nền tối
  mang màu chữ sáng, sẽ đè màu thẻ nếu dùng thẳng).

## Chuyển động

- `AppMotion.quick` 200 ms `easeOutCubic`: đổi tab, đổi trạng thái đáp án.
- `AppMotion.paint` 700 ms `Cubic(0.2, 0, 0, 1)`: vạch được "sơn" thêm.
- Tab Tổng quan: các khối hiện lần lượt, lệch 80 ms.
- Máy bật "giảm chuyển động" thì hiện ngay trạng thái cuối.

## Thành phần

- `GradientCard`: thẻ gradient bo góc 26, chạm được.
- `SignBadge`: biển báo thật trên đĩa trắng (ảnh biển là JPEG nền trắng); mã không có trong danh mục thì để trống.
- `CountChip`: viên trắng mờ `📖 250 câu`.
- `LaneLine` (signature): vạch tiến độ nét đứt → liền; kiểu "từng câu" ở kết quả thi.
- `AppShell`: thanh tab nổi; tab đang chọn là ô tròn đậm. Mỗi tab giữ trạng thái riêng (vị trí cuộn).
  Các màn khác (một chủ đề, bài thi, biển báo, tìm kiếm, giới thiệu) mở đè lên, toàn màn hình.

## Màn hình và chữ trên giao diện

### Tab 1 · Tổng quan
- Thanh trên: `Hạng A1` (chữ to) · viên `Đổi hạng` · nút tròn `Tìm câu hỏi` · nút tròn `Giới thiệu`.
- (Nếu có) thẻ `Tiếp tục bài thi` · `Còn 12:34`.
- Thẻ sunset + biển R.411: `Tiến độ ôn tập` · `79` `/ 250 câu` · vạch · `Mỗi câu đúng ở lần làm gần nhất sơn liền một đoạn vạch.`
- Thẻ sky + biển R.306 (thẻ chính): `Thi thử` · `Hạng A1 · 25 câu · 19 phút`.
- Hai thẻ nhỏ: amber + W.233 `Câu điểm liệt` · `20 câu · sai một câu là trượt`; bloom + R.302a `Ôn câu sai` · `8 câu đang chờ ôn`.
- Thẻ leaf + P.102: `Biển báo` · `Danh mục theo QCVN 41:2024`.

### Tab 2 · Học (`Học theo chủ đề`)
- Mỗi chủ đề một thẻ: `📖 250 câu` · tên chủ đề · `Đúng 79 · Sai 8 · Chưa làm 163` · vạch tiến độ.

### Tab 3 · Câu đã lưu
- Thẻ bloom: `🔖 3 câu` · `Ôn các câu đã lưu` · `→`.
- Danh sách theo thứ tự lưu: số gốc (mono) + 2 dòng đầu câu hỏi; chạm để mở câu đó.
- Trống: `Bạn chưa lưu câu nào` · `Bấm biểu tượng dấu trang khi học để lưu câu muốn xem lại.`

### Tab 4 · Thống kê
- Thẻ biểu đồ: `Số câu đã làm` · `30 ngày qua` · cột chồng mỗi ngày (xanh dưới = `Thi thử`, hồng trên = `Học`;
  ngày trống là chấm xám) · chú giải · `87 Tổng câu` `69 Học` `18 Thi thử` · `Chuỗi ngày học` `23 ngày`.
  Chưa làm gì: `Chưa làm câu nào trong 30 ngày qua.`
  Trình đọc màn hình đọc: `30 ngày qua: 69 câu khi học, 18 câu khi thi thử`.
- Bên dưới giữ như cũ: số lần thi, tỉ lệ đạt, điểm gần nhất, `Câu hay sai`, tiến độ theo chủ đề, lịch sử thi.

### Màn học, màn thi, kết quả, tìm kiếm
Giữ bố cục v1 (vạch dưới thanh tiêu đề, phím số mono, kết quả thi mỗi câu một đoạn), nhận màu v2 qua theme.

## Thử nghiệm "ảnh xe" (nhánh `feat/experiment-cars`, 30/10/2026, chưa chốt)

Ý tưởng sơ khai của Tài, làm thử trước khi quyết:
- **Nền tối kiểu mới**: thẻ gradient tông ngọc đậm, chữ trắng (`CardPalette.dark`); nền sáng giữ pastel (`CardPalette.light`).
  Màu thẻ chọn bằng `CardTone` (sunset, sky, bloom, leaf, amber). Tương phản chữ đo ≥ 5:1 ở cả hai đầu gradient.
  Nền màn tối sâu hơn: `#111214`, panel `#1C1E22`.
- **Màn mở đầu** (`/start`, mỗi lần mở app): ảnh siêu xe mờ dần vào nền, `Ôn thi lý thuyết lái xe`,
  `Bộ 600 câu hỏi chính thức · Hạng A1, A và B`, nút `Bắt đầu` → Tổng quan.
- **Ảnh xe theo hạng**: A1 = xe máy, A = mô tô thể thao, B = ô tô. Hiện ở màn chọn hạng (mỗi hạng một thẻ ảnh)
  và làm nền đầu tab Tổng quan (đổi hạng thì ảnh chuyển mượt). Thanh trạng thái dùng biểu tượng sáng trên ảnh.
- Ảnh: Unsplash License, nguồn và tác giả ở `docs/design/photo-credits.md`, ghi tên trong màn Giới thiệu.
  Ảnh có xe của hãng (Lamborghini, Ducati) chỉ để trang trí, không ngụ ý liên quan tới hãng.

## Thử nghiệm chuyển động (nhánh `feat/motion`, 30/10/2026, chưa chốt)

Mục tiêu: "luôn chuyển động, mượt như app Apple" nhưng không gây rối. Tất cả tắt khi máy bật giảm chuyển động.
- `KenBurns`: ảnh xe (màn mở đầu, nền đầu Tổng quan) phóng to và trôi rất chậm, đi rồi về, chu kỳ ~28 s.
- Thị sai: ảnh nền đầu Tổng quan trôi lên chậm hơn danh sách (40 %) và mờ dần khi cuộn.
- `PressScale`: thẻ gradient và nút `Bắt đầu` thu nhỏ còn 97 % khi nhấn, bật lại có độ nảy nhẹ (`easeOutBack`, 320 ms); bỏ hiệu ứng gợn sóng Material.
- Chuyển màn kiểu iOS (`CupertinoPageTransitionsBuilder`) trên mọi nền tảng.
- `Entrance`: khối hiện lần lượt (Tổng quan, thẻ chủ đề ở tab Học, chữ và nút màn mở đầu).
- `CountUp`: số câu đã đúng đếm từ 0 lên khi mở màn.
- Ảnh hạng A1 đổi sang Honda Air Blade (Wikimedia Commons, CC BY-SA 4.0, đã chỉnh màu cho cùng tông).
