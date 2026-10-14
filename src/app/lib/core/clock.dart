/// Current time, injected so logic and tests never depend on the real clock (`.claude/rules/test-code.md`).
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now();
