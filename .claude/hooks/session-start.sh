#!/usr/bin/env bash
# In tóm tắt trạng thái dự án khi bắt đầu phiên — nội dung này được đưa vào ngữ cảnh của Claude.
ROOT="${CLAUDE_PROJECT_DIR:-.}"
echo "=== App Studio — trạng thái dự án ==="
echo "Hôm nay: $(date +%Y-%m-%d)"
if [ -f "$ROOT/production/status.md" ]; then
  head -n 30 "$ROOT/production/status.md"
else
  echo "Chưa có production/status.md — nếu là phiên đầu, chạy /start."
fi
LATEST=$(ls -1 "$ROOT"/production/sprints/sprint-*.md 2>/dev/null | sort -V | tail -n 1)
[ -n "$LATEST" ] && echo "Sprint mới nhất: $(basename "$LATEST")"
grep -l "\[ĐIỀN\|\[CHỌN" "$ROOT/.claude/docs/project-context.md" >/dev/null 2>&1 && \
  echo "Lưu ý: project-context.md còn mục [ĐIỀN]/[CHỌN] chưa hoàn tất."
exit 0
