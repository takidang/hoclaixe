#!/usr/bin/env bash
# PostToolUse(Write|Edit): tự format file .dart vừa sửa (nếu có dart trong PATH). Không bao giờ chặn.
INPUT=$(cat)
FILE=$(echo "$INPUT" | grep -o '"file_path" *: *"[^"]*"' | head -n1 | sed 's/.*"file_path" *: *"\(.*\)"/\1/')
case "$FILE" in
  *.dart) command -v dart >/dev/null 2>&1 && dart format "$FILE" >/dev/null 2>&1 ;;
esac
exit 0
