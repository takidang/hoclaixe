---
name: ml-train
description: "Huấn luyện/huấn luyện lại model phân loại biển báo và xuất TFLite."
argument-hint: "[baseline | improve | export]"
---

Chủ trì: ml-engineer. Chế độ: $ARGUMENTS (mặc định `baseline`).

- `baseline`: tạo notebook `ml/notebooks/train_signs.ipynb` chạy được trên Google Colab: tải dữ liệu, tăng cường,
  transfer learning, huấn luyện, đánh giá nhanh trên val, lưu model. Ghi rõ các ô cần người dùng chạy và thời gian ước tính.
- `improve`: phân tích lỗi từ `/ml-eval` (lớp hay nhầm, lớp ít ảnh), đề xuất thay đổi (thêm ảnh, đổi augmentation,
  fine-tune thêm lớp, đổi backbone), chờ người dùng chọn.
- `export`: xuất `.tflite` (thử float16/int8 quantization, so sánh kích thước–độ chính xác), `labels.txt` khớp mã danh mục,
  ghi `ml/models/MODEL_CARD.md` (phiên bản, dữ liệu, số đo, hạn chế). Copy sang `src/app/assets/models/` khi được đồng ý.
Mỗi lần huấn luyện ghi một dòng vào `docs/ml/training-log.md` (ngày, cấu hình, số đo val).
