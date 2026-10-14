---
name: release-checklist
description: "Phase 7 — checklist trước khi build bản nộp/demo: chất lượng, bảo mật, build APK, release notes."
---

Chủ trì: release-engineer. Review: qa-engineer, security-reviewer.

Checklist (đánh dấu từng mục, dẫn chứng):
- [ ] Mọi story Must đã xong; không còn bug Critical/High.
- [ ] `flutter analyze` sạch, `flutter test` xanh.
- [ ] security-reviewer quét: không lộ key trong repo và lịch sử git.
- [ ] Version trong `pubspec.yaml` đã tăng; `CHANGELOG.md` cập nhật.
- [ ] Build `flutter build apk --release` thành công; cài và chạy thử trên máy thật.
- [ ] Chatbot chạy với backend production; có xử lý hết quota.
- [ ] Dữ liệu câu hỏi/luật đúng phiên bản trong sources.md.
- [ ] Model TFLite trong assets đúng phiên bản MODEL_CARD; labels.txt khớp danh mục.
- [ ] Quyền camera chỉ xin khi người dùng bấm chụp; từ chối quyền vẫn dùng được "chọn ảnh từ thư viện".
- [ ] Tuyên bố miễn trừ và cảnh báo AI hiển thị đúng.
- [ ] Quyền Android bản release: `aapt dump permissions app-release.apk` không có quyền nào (Module A không cần INTERNET; kiểm cả quyền plugin kéo vào). `android:allowBackup="false"` (ADR-006).
- [ ] Chưa từng commit keystore: `git log --all -- '*.jks' key.properties` rỗng; keystore có bản sao lưu ngoài repo. Build release với `--obfuscate --split-debug-info`.
- [ ] Assets khớp `data/`: chạy `tools/sync_assets.py`, validator PASS trên `src/app/assets`, test hash `content_version.json` xanh.
- [ ] Video demo dự phòng đã quay.
- [ ] (Nếu có web) build web, kiểm tra trên Chrome, deploy.
Ghi kết quả `docs/release/release-<version>.md` (hỏi trước).
