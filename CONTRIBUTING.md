# Hướng dẫn cho thành viên — hoclaixe

> Dành cho **Nguyễn Đỗ Tuấn Kiệt** (thành viên 2) khi clone repo lần đầu.
> Việc cụ thể sẽ do trưởng nhóm (Đặng Lê Tấn Tài) giao — xem mục 4 để biết tìm việc được giao ở đâu.

## 1. Repo này là gì

Repo chứa **cả app lẫn quy trình làm app** cho hai đồ án (LTTTBDD và chuyên ngành CNPM):

| Thư mục | Nội dung | Ai chính |
|---|---|---|
| `src/` | Code app Flutter + backend | Tài (Kiệt phụ khi có Claude Pro) |
| `data/` | Bộ câu hỏi, văn bản luật, danh mục biển báo — **chỉ từ nguồn chính thức** | **Kiệt** |
| `docs/data/` | Ghi nguồn dữ liệu (`sources.md`) | **Kiệt** |
| `docs/reports/` | Báo cáo 2 đồ án | **Kiệt** |
| `docs/srs`, `docs/ux`, `docs/architecture`, `docs/ai`, `docs/ml` | Yêu cầu, thiết kế | Tài (Kiệt đọc để viết báo cáo) |
| `production/` | Tiến độ, sprint, story, rủi ro, bug | Cả hai |
| `ml/` | Notebook, script huấn luyện nhận diện biển báo | Tài |
| `.claude/`, `CLAUDE.md` | Cấu hình Claude Code (agent, skill, rule) — **không sửa nếu chưa bàn** | — |

Đọc thêm `README.md` (tổng quan, module, roadmap).

## 2. Cài đặt lần đầu

1. Chấp nhận lời mời collaborator trên GitHub (kiểm tra email).
2. Cài **Git for Windows** (bắt buộc — hook của dự án chạy bằng bash).
3. Clone:
   ```bash
   git clone https://github.com/takidang/hoclaixe.git
   cd hoclaixe
   git config user.name "Nguyễn Đỗ Tuấn Kiệt"
   git config user.email "<email GitHub của bạn>"
   ```
4. Nếu sẽ chạy app: cài Flutter SDK + Android Studio, chạy `flutter doctor` cho sạch.
5. Khi đã có Claude Pro: cài Claude Code, mở terminal ở thư mục repo, gõ `claude`, rồi `/status`.

## 3. Quy ước nhánh

```
master   ← bản ổn định để nộp/demo. KHÔNG push thẳng.
dev      ← nhánh mặc định, tích hợp hằng ngày.
feature/<mã>-<mô-tả>   ← mỗi việc một nhánh, tách từ dev.
hotfix   ← sửa lỗi gấp trên master (trưởng nhóm xử lý).
```

Quy trình mỗi việc:
```bash
git checkout dev && git pull
git checkout -b feature/data-question-bank      # ví dụ
# ... làm việc, commit ...
git push -u origin feature/data-question-bank
```
Rồi mở **Pull Request vào `dev`** trên GitHub, nhờ Tài review. Không tự merge vào `master`.

Commit message bằng tiếng Anh, ngắn gọn: `docs: add official question bank sources`, `data: import A1 questions`, `feat: ...`, `fix: ...`.

## 4. Nhận việc ở đâu

- `production/status.md` → mục **Phân công**: việc đang giao cho từng người.
- `production/stories/ST-xx.md` → việc code (khi có Claude Pro), có acceptance criteria.
- GitHub Issues / Pull Request comment → trao đổi chi tiết.

## 5. Việc làm được ngay (chưa cần Claude Pro)

**Tìm dữ liệu chính thức** — quan trọng nhất của dự án:
- Bộ câu hỏi sát hạch lý thuyết hiện hành (số câu theo hạng, câu điểm liệt, cấu trúc đề, thời gian, điểm đạt).
- Luật Trật tự, an toàn giao thông đường bộ và các nghị định/thông tư liên quan đang có hiệu lực.
- Quy chuẩn kỹ thuật quốc gia về báo hiệu đường bộ (danh mục biển báo: mã, tên, nhóm, ý nghĩa, hình).

Với mỗi nguồn, ghi vào `docs/data/sources.md`:

| Tên văn bản | Số hiệu | Cơ quan ban hành | Ngày hiệu lực | Link | Ngày truy cập | Ghi chú bản quyền |
|---|---|---|---|---|---|---|

Nguyên tắc:
- **Chỉ nguồn chính thức**: cổng Bộ Công an / Cục CSGT, Cổng TTĐT Chính phủ, cơ sở dữ liệu văn bản pháp luật chính thức.
  Nguồn khác (app, blog) chỉ để đối chiếu, ghi rõ "không chính thức".
- **Không tự soạn** câu hỏi hay nội dung luật. Không chắc → ghi `[CHƯA XÁC MINH]`.
- Kiểm tra văn bản đã bị thay thế/sửa đổi chưa.
- Các con số lấy từ app đối thủ trong README mục 3.1 **phải được xác minh lại**.

**Báo cáo**: dàn ý ở `docs/templates/report-ltttbdd.md` và `docs/templates/report-chuyen-nganh.md`.
Thu thập mẫu báo cáo/bìa/yêu cầu format của giảng viên, lưu vào `docs/reports/`.

## 6. Khi đã có Claude Pro

Mở `claude` trong thư mục repo. Lệnh hay dùng:

| Lệnh | Dùng khi |
|---|---|
| `/status` | Xem dự án đang ở đâu, việc tiếp theo |
| `/data-plan` | Lập kế hoạch dữ liệu cùng agent data-curator |
| `/write-report ltttbdd\|chuyen-nganh <chương>` | Viết báo cáo từ tài liệu và code thật |
| `/dev-story ST-xx` | Code một story được giao (design/backend phụ) |
| `/code-review` | Tự review trước khi mở PR |

Claude Code sẽ luôn hỏi trước khi ghi file và không tự commit — bạn kiểm tra rồi mới đồng ý.

## 7. Tuyệt đối không

- Commit API key, `.env`, `key.properties`, file `.jks`, service account JSON (hook sẽ chặn, nhưng đừng thử).
- Commit ảnh dataset huấn luyện (`ml/dataset/` đã bị ignore).
- Push thẳng vào `master`.
- Đưa dữ liệu không có nguồn vào `data/`.
