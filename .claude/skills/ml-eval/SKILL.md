---
name: ml-eval
description: "Đánh giá định lượng nhận diện biển báo: top-1, top-3, từ chối đúng, confusion matrix, tốc độ; so sánh on-device / Gemini / kết hợp."
argument-hint: "[run | compare | report]"
---

Chủ trì: ml-engineer. Chế độ: $ARGUMENTS (mặc định `run`).

- `run`: script `ml/scripts/evaluate.py` chạy model TFLite trên tập test ảnh thật → `ml/eval/results-<ngày>.csv` + confusion matrix (ảnh).
- `compare`: chạy cùng tập test qua endpoint Gemini vision (theo lô, có delay vì quota) và qua chế độ kết hợp.
- `report`: `docs/ml/eval-report.md` — bảng so sánh 3 phương án (top-1, top-3, từ chối đúng với ảnh không phải biển,
  thời gian suy luận trên máy thật, kích thước model, chi phí quota), 5 lớp hay nhầm nhất kèm ảnh ví dụ, ngưỡng đã chọn và lý do,
  hạn chế. Số liệu này dùng trực tiếp cho chương đánh giá của báo cáo chuyên ngành.
