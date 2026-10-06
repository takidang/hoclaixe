# Trích xuất danh mục biển báo (QCVN 41:2024/BGTVT)

Nguồn và mã SHA-256: `docs/data/sources.md` (mã `QCVN-41-2024`). File gốc `51-bgtvt-kem.pdf` đặt ở
`data/question-bank/raw/` (không commit).

## Chạy
```bash
python -m pip install pymupdf
python tools/extract_signs/extract.py          # sinh data/sign-catalog/signs.json, images/, extract-report.json
python tools/validate_data/validate_signs.py   # kiểm tra + sinh data/sign-catalog/review.md; exit 1 nếu có lỗi
```

## Cách hoạt động
- Chỉ đọc **Phụ lục B–F** của QCVN (ý nghĩa – sử dụng biển cấm, nguy hiểm và cảnh báo, hiệu lệnh, chỉ dẫn, biển phụ).
  Phần thân văn bản bị mất khoảng trắng khi trích chữ nên không dùng làm nội dung, chỉ dùng để đối chiếu mã.
- Mỗi mục "B.4  Biển số P.104 "Cấm xe máy"" → mã, tên (trong ngoặc kép), ý nghĩa (đoạn văn của mục), hình.
- **Gắn hình với mã**: theo nhãn in đậm dưới hình ("a) Biển số P.103a"); một hình duy nhất → theo chú thích
  "Hình B.4 - Biển số P.104". Hình gộp nhiều biển được **cắt theo khoảng trắng** giữa các biển rồi ghép với nhãn theo
  thứ tự đọc; không cắt được thì giữ nguyên hình gộp cho các mã đó (ghi trong `review.md`).
- **Tên**: "P.103b và P.103c "A" và "B"" → mỗi mã một tên theo thứ tự; trường hợp khác dùng chung tên của mục.
- Sửa chữ bị tách ("tr ừ" → "trừ") theo cùng quy tắc với bộ câu hỏi; không nối chữ cái đứng sau mã biển ("R.302 b").

## Đầu ra (`data/sign-catalog/`)
| File | Nội dung |
|---|---|
| `signs.json` | `code`, `name`, `summary` (mô tả ngắn = nguyên văn các câu QCVN nhắc tới đúng mã đó — app hiển thị mặc định), `meaning` (cả đoạn của mục, cho "Xem đầy đủ"), `group` (cam / nguy_hiem / hieu_lenh / chi_dan / phu), `groupName`, `section`, `heading`, `meaning`, `images`, `source` (văn bản, phụ lục, mục, trang) |
| `images/` | Hình biển (độ phân giải gốc trong PDF ~85 px; hình cắt từ hình gộp là PNG) |
| `extract-report.json` | Trường hợp đặc biệt + các chỗ đã nối chữ |
| `review.md` | Danh sách cần soát với PDF + các mã có trong phần thân QCVN nhưng chưa có trong danh mục |

## Giới hạn đã biết (bản 06/10/2026)
- 324 mã (gồm biến thể chỉ có ở nhãn dưới hình, ví dụ DP.127a/b/c, I.444a…m). Còn 81 mã được nêu trong phần thân QCVN nhưng chưa có, chủ yếu **biển đường cao tốc (IE.4xx)** (mô tả ở chương/phụ lục khác). Xem cuối `review.md`.
- 8 mục là biển theo Hiệp định GMS (mã kiểu "G,7", "H,6") — không có mã QCVN, bỏ qua.
- 2 mã chưa có hình, 5 mã chưa có tên, 12 mục hình gộp chưa tách được — xem `review.md`.
- Phụ lục G (vạch kẻ đường) chưa trích xuất.
