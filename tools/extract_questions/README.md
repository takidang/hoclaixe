# Trích xuất bộ 600 câu hỏi

Chuyển PDF chính thức của Cục CSGT thành dữ liệu cho app. Nguồn và mã SHA-256: `docs/data/sources.md`.

## Chuẩn bị (một lần)
```bash
python -m pip install pymupdf
```
Đặt 2 file vào `data/question-bank/raw/` (thư mục này không commit):
- `…600 câu hỏi dùng cho sát hạch GPLX cơ giới đường bộ.pdf`
- `…Hướng dẫn sử dụng bộ câu hỏi sát hạch GPLX (CV 2262.07.5.2025).pdf`

## Chạy
```bash
python tools/extract_questions/extract.py          # sinh questions.json, images/, extract-report.json
python tools/validate_data/validate_questions.py   # kiểm tra + sinh review.md; exit 1 nếu có lỗi
```

## Cách hoạt động
- **Đáp án đúng** = đáp án được **gạch chân** (CV 2262, ghi chú mục I.1). Gạch chân trong PDF là nét kẻ mảnh
  ngay dưới dòng chữ; script khớp nét kẻ với dòng và cột đáp án (có câu xếp đáp án 2 cột, ví dụ câu 301).
- **Chương** lấy theo tiêu đề "CHƯƠNG …" trong PDF; validator đối chiếu số câu mỗi chương với CV 2262.
- **Hạng áp dụng** (`licenseClasses`): A1, A theo Phụ lục 1; B1 theo Phụ lục 2; B trở lên dùng cả 600 câu.
- **Điểm liệt theo hạng** (`criticalFor`): B trở lên = 60 câu Phụ lục 3; A1, A = 20 câu (Phụ lục 1, nhóm 6);
  B1 = 30 câu (Phụ lục 2, nhóm 6). Một câu thuộc 60 câu điểm liệt vẫn có thể là câu thường trong đề A1/A.
- **Hình** gắn với câu hỏi bắt đầu gần nhất phía trên hình (hoặc câu cuối trang trước); giữ định dạng gốc.
- **Sửa chữ bị ngắt dòng** (ví dụ "đường b ộ" → "đường bộ"): chỉ nối khi một âm tiết không có nguyên âm; mọi chỗ
  sửa được ghi vào `extract-report.json` và đưa vào `review.md`.

## Đầu ra (`data/question-bank/`)
| File | Nội dung |
|---|---|
| `questions.json` | 600 câu: `id`, `number`, `chapter`, `content`, `images`, `options`, `correctIndex` (đếm từ 0), `criticalFor`, `licenseClasses`, `sourceVersion`, `sourcePage` |
| `images/` | Hình minh họa `q0301.jpeg`, `q0362_1.png`… |
| `extract-report.json` | Các trường hợp đặc biệt khi trích xuất + danh sách gốc từ CV 2262 |
| `exam-structures.json` | Cấu trúc đề theo hạng và ngày hiệu lực (viết tay từ văn bản, không do script sinh) |
| `review.md` | Danh sách câu cần người soát với PDF (do validator sinh) |

Không sửa tay `questions.json`. Phát hiện sai → sửa script (hoặc ghi ngoại lệ có lý do) rồi chạy lại.
