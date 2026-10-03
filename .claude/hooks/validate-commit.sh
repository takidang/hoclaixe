#!/usr/bin/env bash
# PreToolUse(Bash): chặn git commit nếu phát hiện secret trong phần đã stage.
INPUT=$(cat)
echo "$INPUT" | grep -q 'git[^"]*commit' || exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
STAGED=$(git diff --cached --name-only 2>/dev/null)
[ -z "$STAGED" ] && exit 0

# File nhạy cảm không bao giờ commit
BAD_FILES=$(echo "$STAGED" | grep -E '(^|/)\.env($|\.)|\.jks$|\.keystore$|key\.properties$|service-account.*\.json$' )
if [ -n "$BAD_FILES" ]; then
  echo "CHẶN COMMIT: file nhạy cảm đang được stage:" >&2
  echo "$BAD_FILES" >&2
  echo "Hãy 'git restore --staged <file>' và thêm vào .gitignore." >&2
  exit 2
fi

# Nội dung giống API key (Google API key bắt đầu bằng AIza)
if git diff --cached -U0 | grep -E '^\+' | grep -qE 'AIza[0-9A-Za-z_-]{35}|GEMINI_API_KEY *= *["'"'"']?[A-Za-z0-9_-]{20,}'; then
  echo "CHẶN COMMIT: phát hiện chuỗi giống API key trong thay đổi đã stage." >&2
  echo "Đưa key vào biến môi trường phía backend, không để trong code." >&2
  exit 2
fi
exit 0
