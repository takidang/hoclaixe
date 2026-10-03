---
name: gate-check
description: "Kiểm tra điều kiện qua phase: đầu ra đủ và đạt chất lượng chưa."
argument-hint: "<tên phase: discovery | requirements | design | setup | sprint | testing | release | report>"
---

Phase: $ARGUMENTS
1. Đọc tiêu chí gate trong `.claude/docs/phases.md` và các file đầu ra tương ứng.
2. Đánh giá từng tiêu chí: PASS / FAIL / CHƯA RÕ, có dẫn chứng (file, mục).
3. Kết luận: PASS (cập nhật status sang phase tiếp — hỏi trước) hoặc FAIL kèm danh sách việc cần làm.
Đánh giá khắt khe nhưng thực tế với đồ án sinh viên 2 người.
