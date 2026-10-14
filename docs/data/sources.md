# Nguồn dữ liệu

> Quản lý: data-curator (Kiệt). Mọi dữ liệu trong `data/` phải truy được về một dòng ở đây.
> File gốc lưu ở `data/question-bank/raw/` (không commit) — kiểm tra đúng file bằng SHA-256.

## 1. Văn bản và bộ câu hỏi đang dùng

| Mã tham chiếu | Văn bản | Cơ quan | Ban hành | Hiệu lực | Dùng cho | Bản chính thức? |
|---|---|---|---|---|---|---|
| `CSGT-600-2025` | Bộ 600 câu hỏi dùng cho sát hạch lái xe cơ giới đường bộ | Cục CSGT – Bộ Công an | 2025 | 01/6/2025 (bắt buộc toàn quốc 01/9/2025) | Nội dung câu hỏi, đáp án, hình | Có |
| `CV-2262-2025` | Công văn 2262/CSGT-P5 về việc sử dụng bộ 600 câu hỏi | Cục CSGT | 07/5/2025 | 01/6/2025 | Chương, đáp án = phần gạch chân, pool A1/A (PL1), B1 (PL2), 60 câu điểm liệt (PL3), cấu trúc đề theo chương (mục II) | Có |
| `TT-12-2025` | Thông tư 12/2025/TT-BCA về sát hạch, cấp GPLX; cấp, sử dụng GPLX quốc tế | Bộ Công an | 28/02/2025 | Các phần dùng ở đây còn hiệu lực **đến hết 28/02/2027** (TT 108/2026, Điều 41 khoản 6) | Thời gian làm bài, điểm đạt, quy tắc điểm liệt (đề hiện hành) | Có — PDF có chữ ký số Cổng TTĐT Chính phủ (06/3/2025) |
| `TT-108-2026` | Thông tư 108/2026/TT-BCA về sát hạch, cấp GPLX; cấp, sử dụng GPLX quốc tế (thay TT 12/2025) | Bộ Công an | 29/6/2026 | 01/7/2026; **nội dung sát hạch lý thuyết mới từ 01/3/2027** (Điều 41 khoản 2) | Cấu trúc đề từ 01/3/2027 (chưa đủ để tạo đề) | Có (bản scan) |
| `TT-108-2026-docx` | Bản .docx của TT 108/2026 | thuvienphapluat.vn (metadata: tác giả "User", 25/8/2026) | — | — | Chỉ để tìm kiếm toàn văn; đã đối chiếu khớp bản scan ở Điều 41, PL I, PL III | **Không** — không trích dẫn từ bản này |
| `LUAT-36-2024` | Luật Trật tự, an toàn giao thông đường bộ số 36/2024/QH15 | Quốc hội | 27/6/2024 | 01/01/2025 | Mô tả loại xe của từng hạng trên màn chọn hạng (Điều 57 khoản 1) | Bản .docx từ thuvienphapluat.vn (trang thứ cấp), bản gốc chưa hợp nhất. Đã kiểm tra: Luật 118/2025 **không sửa** khoản 1 Điều 57 |
| `LUAT-118-2025` | Luật số 118/2025/QH15 sửa đổi, bổ sung một số điều của 10 luật có liên quan đến an ninh, trật tự (Điều 7 sửa Luật 36/2024/QH15) | Quốc hội | 10/12/2025 | 01/7/2026 (Điều 11) | Kiểm tra sửa đổi Điều 57 | Có (bản scan) |
| `QCVN-41-2024` | QCVN 41:2024/BGTVT — Quy chuẩn kỹ thuật quốc gia về báo hiệu đường bộ (ban hành kèm Thông tư 51/2024/TT-BGTVT) | Bộ GTVT | 2024 | 01/01/2025 | Danh mục biển báo (`data/sign-catalog/`): mã, tên, ý nghĩa, hình — Phụ lục B–F | Có (file đính kèm trên datafiles.chinhphu.vn) |

## 2. File gốc

| Mã | Tên file | Nguồn tải | Ngày tải | SHA-256 |
|---|---|---|---|---|
| `CSGT-600-2025` | `725823572_600 câu hỏi dùng cho sát hạch GPLX cơ giới đường bộ.pdf` (188 trang, PDF chữ) | https://csgt.bocongan.gov.vn/van-ban | 04/10/2026 | `6a6dab8543eb334b36ac9de6abcd938e864f2e0e915be27c3a2157ee6e518575` |
| `CV-2262-2025` | `2071319603_Hướng dẫn sử dụng bộ câu hỏi sát hạch GPLX (CV 2262.07.5.2025).pdf` (6 trang, PDF chữ) | https://csgt.bocongan.gov.vn/van-ban | 04/10/2026 | `dcb0b42473a23af3b006ed07cfd3a728254eb3d5263f6a26d0536c576d69e634` |
| `TT-12-2025` | `15-bca.signed.pdf` (122 trang, scan) | https://chinhphu.vn/?pageid=27160&docid=213022 | 04/10/2026 | `307f993f81e3949da59812a0cbabef58f6d1c4b62caecf8362b84c65ae949ed3` |
| `TT-108-2026` | `thong-tu-so-108.2026.tt-bca-ngay-29.6.2026-ban-day-du-v03.pdf` (134 trang, scan) | https://csgt.bocongan.gov.vn/van-ban/thong-tu-108-2026 | 04/10/2026 | `7f879c2404948203d693a0109b1f584a5484c1514b5c5ea6c6d4d7c956983c71` |
| `TT-108-2026-docx` | `108_2026_TT-BCA_704772.docx` | https://thuvienphapluat.vn/van-ban/Giao-thong-Van-tai/Thong-tu-108-2026-TT-BCA-sat-hach-cap-giay-phep-lai-xe-704772.aspx (trang thứ cấp) | 04/10/2026 | `0f14ead202f492ac64a3cdd1d249acb166f164e58ea6e6a1629a161f8f8464e8` |
| `LUAT-118-2025` | `luatso118.2025.pdf` (28 trang, scan) | vanban.chinhphu.vn | 14/10/2026 | `a9798bfab6120963834d26559ab8614003ca3012de1d1846305495e8bb4300b6` |
| `LUAT-36-2024` | `36_2024_QH15_444251.docx` | thuvienphapluat.vn (trang thứ cấp) | 14/10/2026 | `5182b27c133f3cd05d69f187c352ec34e70d28dfdabba416740116c75c2617ba` |
| `QCVN-41-2024` | `51-bgtvt-kem.pdf` (403 trang, PDF chữ; phụ lục dùng được, phần thân mất khoảng trắng) | https://datafiles.chinhphu.vn/cpp/files/vbpq/2024/11/51-bgtvt-kem.pdf | 04/10/2026 | `b6b99d0a0aeb13fe79072831857ece15bb254d8fb7817e80e4a2739a0d2145ce` |

Ghi chú sử dụng: bộ câu hỏi và văn bản là tài liệu công khai do Bộ Công an / Cục CSGT ban hành để người học sử dụng;
nhiều app ôn thi trên Google Play đang dùng lại bộ 600 câu. hoclaixe là đồ án sinh viên, chỉ dùng để học tập và demo
khi chấm điểm, không phát hành thương mại; app ghi rõ nguồn và tuyên bố miễn trừ. Nếu sau này phát hành công khai
→ xem lại điều kiện sử dụng (hỏi giảng viên / nguồn ban hành).

## 3. Trích dẫn cụ thể (đã đối chiếu bản chính thức, 04/10/2026)

| Nội dung | Giá trị | Nguồn (trang trong file PDF) |
|---|---|---|
| Đáp án đúng | Phần gạch chân dưới câu hỏi | CV-2262-2025, mục I.1, ghi chú |
| Số câu mỗi chương | I: 1–180 · II: 181–205 · III: 206–263 · IV: 264–300 · V: 301–485 · VI: 486–600 | CV-2262-2025, mục I.1 |
| Pool A1, A | 250 câu, 20 câu điểm liệt | CV-2262-2025, mục I.2.3 + Phụ lục 1 |
| Pool B1 | 300 câu, 30 câu điểm liệt | CV-2262-2025, mục I.2.2 + Phụ lục 2 |
| Hạng B trở lên | 600 câu, 60 câu điểm liệt | CV-2262-2025, mục I.2.1 + Phụ lục 3 |
| Đề A1, A (hiện hành) | 25 câu: 8 ch.I · 1 điểm liệt · 1 ch.II · 1 ch.III hoặc IV · 8 ch.V · 6 ch.VI | CV-2262-2025, mục II.5 |
| Đề B (hiện hành) | 30 câu: 8 ch.I · 1 điểm liệt · 1 ch.II · 1 ch.III · 1 ch.IV · 9 ch.V · 9 ch.VI | CV-2262-2025, mục II.1 |
| A1, A: thời gian, điểm đạt | 19 phút; 24 câu 1 điểm + 1 câu điểm liệt; mỗi câu 2–4 ý; **A1 đạt từ 21/25, A đạt từ 23/25**; sai câu điểm liệt → không đạt | TT-12-2025, Phụ lục II, mục A.I (tr. 35–36) |
| B: thời gian, điểm đạt | 30 câu, 20 phút, **đạt tối thiểu 27**; mỗi đề 1 câu điểm liệt; sai → không đạt | TT-12-2025, Phụ lục IV, mục A (tr. 47–48) |
| Hiệu lực chuyển tiếp | Lý thuyết theo TT 108 từ 01/3/2027; Phụ lục II, IV mục A… của TT 12/2025 hiệu lực đến hết 28/02/2027 | TT-108-2026, Điều 41 khoản 2, 6 (tr. 36–37) |
| A1, A từ 01/3/2027 | 40 câu, 27 phút, đạt từ 36/40 | TT-108-2026, Phụ lục I, mục A.I (tr. 39) |
| B từ 01/3/2027 | 50 câu, 33 phút, đạt tối thiểu 45 | TT-108-2026, Phụ lục III, mục A (tr. 55–56) |
| Điểm liệt từ 01/3/2027 | **Không được nhắc tới** trong TT 108 (đã tìm toàn văn bản .docx) | TT-108-2026 |
| Bộ câu hỏi từ 01/3/2027 | TT 108 không ban hành bộ câu hỏi; giao Cục CSGT xây dựng | TT-108-2026 (toàn văn) |
| Loại xe hạng A1, A, B | Nguyên văn trong `S.classVehicles` (`src/app/lib/core/strings.dart`) | LUAT-36-2024, Điều 57 khoản 1 điểm a, b, d |
| Sửa đổi Điều 57 Luật 36/2024 | Chỉ sửa **khoản 9** (thẩm quyền quy định mẫu GPLX: Bộ trưởng Bộ Công an). Khoản 1 (phân hạng) giữ nguyên. Các khoản thay/bỏ cụm từ cuối Điều 7 (khoản 21–23) không nhắc Điều 57 | LUAT-118-2025, Điều 7 khoản 11 (tr. 18), khoản 21–23 (tr. 21–22) |

## 4. Chưa có / cần bổ sung
- Danh mục biển báo: đã trích 294 mã từ QCVN 41:2024 (Phụ lục B–F). Còn thiếu biển cao tốc IE.4xx, một số biến thể, Phụ lục G vạch kẻ đường — xem `tools/extract_signs/README.md`.
- Văn bản gốc Thông tư 51/2024/TT-BGTVT (để trích số hiệu, ngày ký) — hiện chỉ có file quy chuẩn đính kèm.
- (Không gấp) Bản chính thức của Luật 36/2024/QH15 để thay bản .docx thứ cấp — chỉ cần nếu giảng viên hỏi nguồn; khoản 1 Điều 57 không bị Luật 118/2025 sửa.
- Nghị định 168/2024/NĐ-CP — cho tra cứu luật và RAG (làm sau).
- Hướng dẫn của Cục CSGT về bộ câu hỏi/cấu trúc đề áp dụng từ 01/3/2027 (khi có).
