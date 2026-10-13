> ⚠️ **Lỗi thời (ghi chú 13/10/2026)** — đây là ghi chú khảo sát ngày 08/10, giữ lại làm tư liệu.
> Quyết định thực tế: **không dùng dữ liệu của `tdytools-gplx`** (không giấy phép; chia chương lệch CV 2262/CSGT-P5).
> Dữ liệu của app trích trực tiếp từ PDF chính thức — xem `docs/data/sources.md`, `tools/extract_questions/`.
> Cấu trúc đề đã xác minh từ văn bản gốc: `data/question-bank/exam-structures.json`.

# GPLX — ghi chú khảo sát nguồn dữ liệu (2026-10-08)

## Mục tiêu
App Flutter ôn thi lý thuyết GPLX (đồ án môn Lập trình trên thiết bị di động), dùng bộ 600 câu Bộ Công an 2025, hỗ trợ theo từng hạng bằng.

## Nguồn dữ liệu đã chọn: `rinaheart/tdytools-gplx` (đã clone tại `Desktop\tdytools-gplx`)
- Là web app React 19 + Vite + Dexie (PWA), chỉ làm hạng B. Không có LICENSE → ghi nguồn trong báo cáo.
- Dữ liệu dùng lại cho Flutter: `data/*.json` + `public/images/` (318 ảnh, đã kiểm tra không thiếu ảnh nào).
  - `questions.json`: 600 câu. Trường: `questionNumber, chapterId, chapterName, category, content, options[{id,text,isCorrect}], isCritical, criticalSetId?, image?{src,type}, source{document,page}`.
  - `chapters.json`: 6 chương / category: rules (1–166), culture (167–192), drivingTechnique (193–248), structureRepair (249–283), signs (284–485), scenario (486–600).
  - `critical-sets.json`: 60 câu điểm liệt (Phụ lục III, CV 2262/CSGT-P5).
  - `exam-profiles.json`: chỉ có hạng B (30 câu, 20 phút, đạt ≥27, sai câu điểm liệt = trượt) + placeholder TT 108/2026 (áp dụng 01/03/2027).
- Logic sinh đề tham khảo: `src/services/examEngine.ts` (blueprint, seeded RNG, chống trùng) → viết lại bằng Dart.

## Cấu trúc đề theo hạng (CV 2262/CSGT-P5, hiệu lực 01/06/2025)
| Hạng | Bộ ôn | Câu/đề | Quy định | Điểm liệt | Văn hóa | Kỹ thuật | Cấu tạo | Biển báo | Sa hình | Thời gian · Đạt |
|---|---|---|---|---|---|---|---|---|---|---|
| A1, A | 250 (20 điểm liệt) | 25 | 8 | 1 | 1 | 1 (KT hoặc cấu tạo) | – | 8 | 6 | 19' · ≥21 |
| B1 | 300 (30 điểm liệt) | 25 | 8 | 1 | 1 | 1 (KT hoặc cấu tạo) | – | 8 | 6 | chưa xác minh |
| B | 600 | 30 | 8 | 1 | 1 | 1 | 1 | 9 | 9 | 20' · ≥27 |
| C1 | 600 | 35 | 10 | 1 | 1 | 2 | 1 | 10 | 10 | chưa xác minh |
| C | 600 | 40 | 10 | 1 | 1 | 2 | 1 | 14 | 11 | chưa xác minh |
| D1, D2, D, BE, C1E, CE, D1E, D2E, DE | 600 | 45 | 10 | 1 | 1 | 2 | 1 | 16 | 14 | chưa xác minh |

## Việc còn thiếu
1. Dữ liệu **chưa đánh dấu câu nào thuộc bộ 250 (A1/A) và 300 (B1)** → cần thêm trường `licenseClasses` cho từng câu, lấy theo PDF 600 câu gốc.
2. Thêm exam profile cho các hạng ngoài B; xác minh thời gian/điểm đạt của B1, C1, C, nhóm D từ văn bản gốc.
3. Thiết kế để thay được bộ đề (bộ mới theo TT 108/2026 từ 01/03/2027, theo ghi chú trong repo; chưa tự xác minh).

## Môi trường máy
- Windows. Đã cài `gh` (đăng nhập `takidang`) và `yt-dlp`. Không cài Agent-Reach (chỉ cần GitHub + YouTube).
- PowerShell chặn `npm.ps1` → dùng `npm.cmd` hoặc `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

## Nguồn (truy cập 2026-10-08)
- Repo dữ liệu: https://github.com/rinaheart/tdytools-gplx (commit 8553ebc, không có LICENSE)
- Văn bản gốc: Công văn 2262/CSGT-P5 ngày 07/05/2025 (Cục CSGT – Bộ Công an), hiệu lực 01/06/2025 — cần lấy bản gốc để đối chiếu bảng cấu trúc đề.
- Bài báo tổng hợp cấu trúc đề (nguồn thứ cấp, chỉ để tham khảo):
  - https://lsvn.vn/cau-truc-bo-de-sat-hach-cap-giay-phep-lai-xe-cac-hang-a157613.html
  - https://baoquocte.vn/chi-tiet-cau-truc-de-thi-ly-thuyet-lai-xe-o-to-cac-hang-tu-ngay-162025-314282.html
  - https://luatvietnam.vn/giao-thong/thi-bang-lai-xe-a1-863-104039-article.html
