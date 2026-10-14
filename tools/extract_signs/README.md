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
- Đọc **Phụ lục B–F**, **Phụ lục G** (vạch kẻ đường — nhóm `vach_ke`, mã dạng "Vạch 1.1", mô tả ngắn = đoạn "Ý nghĩa sử dụng"; chỉ gắn hình có chú thích nêu đúng vạch hoặc nằm sau dòng "Minh họa:", bỏ các sơ đồ bố trí chung) và **Điều 47** (biển chỉ dẫn trên đường cao tốc IE.4xx — nhóm `cao_toc`; hình cắt từ vùng trang phía trên chú thích "Hình N", kể cả hình vẽ vector) của QCVN (ý nghĩa – sử dụng biển cấm, nguy hiểm và cảnh báo, hiệu lệnh, chỉ dẫn, biển phụ).
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
| `overrides.json` (đầu vào, sửa tay) | Bỏ mã không phải biển riêng, sửa tên, chụp lại hình từ vùng trang PDF, thêm mã còn thiếu — mỗi mục ghi trang PDF. Áp ở bước cuối; hình không còn mã nào dùng bị xóa |
| `review-results/` | Kết quả soát của người (JSON xuất từ trang soát) |

## Sửa sau soát lần 1 (14/10/2026)
Kiệt soát 397 mục, báo 29 lỗi (`review-results/2026-10-14-kiet.json`); sửa bằng `overrides.json`:
- Tên biển cao tốc lấy theo **bảng "Số hiệu và tên biển chỉ dẫn" mục 46.8 (trang 43–44)** thay vì đoán từ câu văn
  (trước đây lấy nhầm "Sử dụng chữ màu trắng…", "Thì sử dụng…").
- Bỏ 7 mã gốc cao tốc (IE.453, 456, 459, 463, 464, 467, 468) — biển thực tế là các biến thể a/b/c; IE.467 chỉ là câu
  "không lắp IE.467 thì dùng W.207g và W.238". Thêm IE.455, IE.460, IE.464a (bị sót).
- Lỗi in trong QCVN: hình "h)" mục D.15 ghi nhãn R.413p nhưng là R.412p → bỏ R.413p, gán hình cho R.412p.
- I.428b/c: hai nhãn chung một dòng → trước đây cả 2 hình gán cho I.428b. I.428a: "xăng d ầu" → "xăng dầu".
- Vạch 4.2, 6.1, 9.3, 9.5: chụp hình minh họa từ trang PDF. Vạch 3.2, 3.3: QCVN không có hình riêng → dùng Hình G.14.
  Vạch 3.4: không có hình (`noImageReason`).
- `validate_signs.py` thêm lỗi chặn: tên rỗng, tên là câu văn, chữ bị tách, thiếu hình mà không ghi lý do.
- Soát lần 2: `python tools/review_ui/make_sign_review.py --fixed-only` → `review-fixed.html` (chỉ mục đã sửa).

## Giới hạn đã biết (bản 14/10/2026)
- 392 mục: 323 biển từ Phụ lục B–F, 39 biển cao tốc (Điều 47), 30 vạch kẻ đường (Phụ lục G).
  Còn 47 mã biển nêu trong phần thân QCVN chưa có (xem cuối `review.md`).
- 8 mục là biển theo Hiệp định GMS (mã kiểu "G,7", "H,6") — không có mã QCVN, bỏ qua.
- Chưa có hình: vạch 3.4 (QCVN không có hình minh họa).
- Sơ đồ "Bố trí vạch…" (minh họa cách kẻ ở nút giao) không đưa vào danh mục.
