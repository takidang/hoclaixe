---
name: write-report
description: "Phase 8 — viết/cập nhật báo cáo đồ án từ tài liệu và code thật."
argument-hint: "<ltttbdd | chuyen-nganh> [chương số | outline | all]"
---

Chủ trì: report-writer. Yêu cầu: $ARGUMENTS

1. Xác định báo cáo nào và dàn ý: `docs/templates/report-ltttbdd.md` hoặc `docs/templates/report-chuyen-nganh.md`.
   Nếu người dùng có mẫu của giảng viên trong `docs/reports/`, dùng mẫu đó thay thế.
2. Thu thập nguồn: SRS, ADR, architecture, UX spec, rag-design, eval-report, test-report, sprint, dev-log, code,
   `docs/ml/*` và `ml/models/MODEL_CARD.md`.
3. Viết từng chương vào `docs/reports/<báo cáo>/chuong-<n>.md`. Sơ đồ dùng Mermaid (người dùng xuất ảnh khi dàn trang).
4. Đánh dấu `[CẦN ẢNH]`, `[CẦN SỐ LIỆU]`, `[CẦN TRÍCH DẪN]` thay vì bịa.
5. Kiểm tra chéo: số liệu trong báo cáo khớp test-report, eval-report, dữ liệu.
6. Nhắc: hai báo cáo không được sao chép nguyên văn của nhau — cùng sản phẩm nhưng góc nhìn và trọng tâm khác.
