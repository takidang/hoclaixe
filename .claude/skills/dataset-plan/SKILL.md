---
name: dataset-plan
description: "Lập kế hoạch dữ liệu ảnh biển báo: danh sách lớp, nguồn ảnh, giấy phép, gán nhãn, chia tập, mốc số lượng tối thiểu."
---

Chủ trì: ml-engineer. Hỗ trợ: data-curator.

1. Lấy danh sách biển xuất hiện trong bộ câu hỏi thi từ `data/sign-catalog/` (data-curator xác nhận mã theo quy chuẩn hiện hành).
2. Dùng WebSearch tìm bộ dữ liệu biển báo Việt Nam công khai; ghi tên, link, giấy phép, số lớp, mức khớp với danh mục.
   Bộ không rõ giấy phép → đánh dấu, không dùng khi chưa được người dùng đồng ý.
3. Kế hoạch tự chụp bổ sung: phân công 2 thành viên, khu vực, số ảnh mỗi lớp, góc/ánh sáng khác nhau.
4. Quy ước thư mục `ml/dataset/<split>/<mã_biển>/` và lớp `khong_phai_bien_bao`.
5. Chia train/val/test; tập test chỉ ảnh chụp thật. Đề xuất mốc tối thiểu ảnh/lớp và ngày kiểm tra (15/11, giữa Sprint 3).
6. Ghi `docs/ml/dataset-plan.md` và cập nhật `production/risks.md` (hỏi trước).
