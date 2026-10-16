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
   git clone -c core.longpaths=true https://github.com/takidang/hoclaixe.git
   cd hoclaixe
   git config user.name "Nguyễn Đỗ Tuấn Kiệt"
   git config user.email "<email GitHub của bạn>"
   ```
4. Nếu sẽ chạy app: làm theo **mục 2a** ngay dưới.
5. Khi đã có Claude Pro: cài Claude Code, mở terminal ở thư mục repo, gõ `claude`, rồi `/status`.

## 2a. Cài Flutter và chạy app (Android hoặc web)

Git clone chỉ tải **code**; Flutter là công cụ phải cài riêng trên từng máy (giống phải cài Python mới chạy được file `.py`).

**Bước 1 — Cài Flutter (một lần)**
1. Cài **VS Code**, mở tab Extensions, cài **Flutter** (của Dart Code).
2. `Ctrl+Shift+P` → gõ **Flutter: New Project** → VS Code báo chưa có SDK → **Download SDK** → chọn thư mục
   **không dấu cách, không dấu tiếng Việt**, ví dụ `C:\src\flutter`.
3. Khi được hỏi **Add SDK to PATH** → đồng ý. **Đóng hết VS Code/terminal rồi mở lại**, gõ `flutter --version`
   (team dùng **Flutter 3.47.x**; bản cũ hơn → `flutter upgrade`).
4. Muốn chạy Android: cài **Android Studio** → mở lần đầu cho nó tải Android SDK → chạy `flutter doctor --android-licenses`, bấm `y` hết.

**Bước 2 — Kiểm tra máy** (ở thư mục gốc repo):
```powershell
powershell -ExecutionPolicy Bypass -File tools\check-setup.ps1
```
Script in `[OK]` / `[!!]` / `[X]` kèm cách sửa. Hết `[X]` là chạy được.

**Bước 3 — Chạy app**
```powershell
cd src\app
flutter pub get
flutter run -d chrome --web-port 8080     # web: nhanh, không cần emulator
flutter run                               # Android: chọn emulator/điện thoại trong danh sách
```
- **Web**: chỉ để xem/thử nhanh; bản nộp là Android. Tiến độ lưu trong trình duyệt và **gắn với cổng** —
  luôn dùng `--web-port 8080`, đổi cổng là thấy app như mới cài.
- **Android emulator**: Android Studio → Device Manager → **Create Virtual Device** → Pixel 7 → bản Android API 35/36 → ▶.
  Lần build Android đầu mất vài phút (Gradle tải thư viện).
- **Điện thoại thật**: Cài đặt → Thông tin điện thoại → bấm 7 lần "Số hiệu bản tạo" → Tùy chọn nhà phát triển → bật **Gỡ lỗi USB** → cắm cáp → cho phép.

**Không muốn gõ `cd src\app`**: mở cả repo bằng VS Code → **F5** chạy app (chọn cấu hình Android hoặc web cổng 8080),
**Ctrl+Shift+B** chạy `flutter test`, các lệnh khác ở Ctrl+Shift+P → "Tasks: Run Task" (`.vscode/launch.json`, `tasks.json`).

**Khi dữ liệu trong `data/` thay đổi** (ở thư mục gốc repo):
```powershell
python tools/validate_data/validate_questions.py
python tools/validate_data/validate_signs.py
python tools/sync_assets.py      # chép vào src/app/assets + content_version.json
```
rồi chạy `flutter test` (test mã băm bắt lỗi quên đồng bộ).

**Lỗi hay gặp**
| Lỗi | Cách sửa |
|---|---|
| `flutter : The term 'flutter' is not recognized` | Chưa cài Flutter hoặc chưa vào PATH → bước 1; nhớ mở lại terminal |
| `Filename too long` khi clone, rồi `No pubspec.yaml file found` | `git config --global core.longpaths true` rồi clone lại; để repo ở đường dẫn ngắn (vd. `C:\code\hoclaixe`) |
| `Could not find or load main class org.gradle.wrapper.GradleWrapperMain` | Repo cũ thiếu Gradle wrapper → `git pull`, rồi `flutter clean` |
| Web hiện "Không mở được dữ liệu tiến độ trên máy" | Code cũ chưa hỗ trợ web → `git pull`, rồi tắt hẳn app và `flutter run` lại |
| Đang chạy app rồi mới `git pull` → lỗi lạ | Hot reload không nạp thay đổi lớn: bấm `q` rồi `flutter run` lại |
| **Đừng** chạy `flutter create .` | Lệnh này sinh file `test/widget_test.dart` mẫu làm hỏng test và ghi đè `pubspec.lock` |

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
