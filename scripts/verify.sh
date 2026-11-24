#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILURES=0

fail() {
  echo "FAIL: $1" >&2
  FAILURES=$((FAILURES + 1))
}

echo "==> Checking shell syntax"
for SH_FILE in "$BASE_DIR/sync_config.sh" "$BASE_DIR/scripts"/*.sh; do
  [ -f "$SH_FILE" ] || continue
  if bash -n "$SH_FILE"; then
    echo "OK   $(basename "$SH_FILE")"
  else
    fail "bash syntax error in $SH_FILE"
  fi
done

echo "==> Checking JavaScript syntax"
for JS_FILE in "$BASE_DIR/scripts"/*.mjs "$BASE_DIR/scripts/lib"/*.mjs; do
  [ -f "$JS_FILE" ] || continue
  if node --check "$JS_FILE"; then
    echo "OK   ${JS_FILE#"$BASE_DIR/"}"
  else
    fail "JS syntax error in $JS_FILE"
  fi
done

echo "==> Running script unit tests"
if ! node --test "$BASE_DIR/scripts/scripts.spec.mjs"; then
  fail "unit tests failed"
fi

echo "==> Validating skills"
if ! node "$BASE_DIR/scripts/validate_skills.mjs" "$BASE_DIR/skills"; then
  fail "skill validation failed"
fi

echo "==> Validating source agents and models.yml"
if ! node "$BASE_DIR/scripts/validate_agents.mjs" "$BASE_DIR/agents" opencode; then
  fail "source agent validation failed"
fi

echo "==> Validating installed agents"
INSTALLED_AGENT_CHECKS=(
  "$HOME/.config/opencode/agents|opencode"
  "$HOME/.claude/agents|claude"
  "$HOME/.codex/agents|codex"
  "$HOME/.gemini/config/agents|antigravity"
)

for ENTRY in "${INSTALLED_AGENT_CHECKS[@]}"; do
  DIR="${ENTRY%%|*}"
  SCHEMA="${ENTRY##*|}"
  if [ -d "$DIR" ]; then
    echo "--- $DIR ($SCHEMA) ---"
    if ! node "$BASE_DIR/scripts/validate_agents.mjs" "$DIR" "$SCHEMA"; then
      fail "installed agent validation failed for $DIR"
    fi
  fi
done

echo "==> Verifying global/AGENTS.md parity across installed harnesses"
AGENT_FILES=(
  "$HOME/.codex/AGENTS.md"
  "$HOME/.config/opencode/AGENTS.md"
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.gemini/config/AGENTS.md"
  "$HOME/.pi/agent/AGENTS.md"
  "$HOME/.dsh/AGENTS.md"
)

for AGENT_FILE in "${AGENT_FILES[@]}"; do
  AGENT_DIR="$(dirname "$AGENT_FILE")"
  if [ ! -d "$AGENT_DIR" ]; then
    echo "SKIP $AGENT_FILE (no $AGENT_DIR)"
    continue
  fi

  if [ ! -f "$AGENT_FILE" ]; then
    fail "$AGENT_FILE is missing (run ./sync_config.sh)"
    continue
  fi

  if diff -q "$BASE_DIR/global/AGENTS.md" "$AGENT_FILE" >/dev/null; then
    echo "OK   $AGENT_FILE"
  else
    fail "$AGENT_FILE differs from global/AGENTS.md (run ./sync_config.sh)"
  fi
done

if [ "$FAILURES" -gt 0 ]; then
  echo "Verification failed with $FAILURES error(s)." >&2
  exit 1
fi

echo "All checks passed."
