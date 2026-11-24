#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_ERRORS=0

record_error() {
  echo "  ERROR: $1" >&2
  SYNC_ERRORS=$((SYNC_ERRORS + 1))
}

is_safe_entry_name() {
  local ENTRY_NAME="$1"

  if [ -z "$ENTRY_NAME" ] || [ "$ENTRY_NAME" = "." ] || [ "$ENTRY_NAME" = ".." ]; then
    return 1
  fi

  case "$ENTRY_NAME" in
    */*|/*)
      return 1
      ;;
  esac

  return 0
}

sync_skills() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"
  local MANIFEST_FILE="$DEST_DIR/.sync_config_manifest"
  local TEMP_MANIFEST
  local SKILL_PATH
  local SKILL_NAME

  mkdir -p "$DEST_DIR"
  TEMP_MANIFEST="$(mktemp "$DEST_DIR/.sync_manifest.XXXXXX")"

  while IFS= read -r SKILL_PATH; do
    [ -n "$SKILL_PATH" ] || continue
    SKILL_NAME="$(basename "$SKILL_PATH")"

    if ! is_safe_entry_name "$SKILL_NAME"; then
      echo "  skipping unsafe skill entry: $SKILL_NAME" >&2
      continue
    fi

    rsync -a --delete --delete-excluded --exclude 'evals/' "$SKILL_PATH" "$DEST_DIR/"
    printf '%s\n' "$SKILL_NAME" >> "$TEMP_MANIFEST"
  done < <(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '.*' | sort)

  if [ -f "$MANIFEST_FILE" ]; then
    while IFS= read -r OLD_SKILL; do
      [ -n "$OLD_SKILL" ] || continue
      if ! is_safe_entry_name "$OLD_SKILL"; then
        echo "  skipping unsafe manifest entry: $OLD_SKILL" >&2
        continue
      fi

      if ! grep -qxF "$OLD_SKILL" "$TEMP_MANIFEST"; then
        rm -rf -- "$DEST_DIR/$OLD_SKILL"
      fi
    done < "$MANIFEST_FILE"
  fi

  chmod 0644 "$TEMP_MANIFEST"
  mv -f -- "$TEMP_MANIFEST" "$MANIFEST_FILE"
}

sync_skill_scripts() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"
  local MANIFEST_FILE="$DEST_DIR/.sync_config_scripts_manifest"
  local TEMP_MANIFEST
  local SCRIPT_PATH
  local SCRIPT_NAME

  mkdir -p "$DEST_DIR"
  TEMP_MANIFEST="$(mktemp "$DEST_DIR/.sync_scripts_manifest.XXXXXX")"

  while IFS= read -r SCRIPT_PATH; do
    [ -n "$SCRIPT_PATH" ] || continue
    SCRIPT_NAME="$(basename "$SCRIPT_PATH")"

    if ! is_safe_entry_name "$SCRIPT_NAME"; then
      echo "  skipping unsafe script entry: $SCRIPT_NAME" >&2
      continue
    fi

    install -m 0755 "$SCRIPT_PATH" "$DEST_DIR/"
    printf '%s\n' "$SCRIPT_NAME" >> "$TEMP_MANIFEST"
  done < <(find "$SOURCE_DIR" -mindepth 3 -maxdepth 3 -path '*/scripts/*' -type f ! -name '.*' -perm -u+x | sort)

  sort -u -o "$TEMP_MANIFEST" "$TEMP_MANIFEST"

  if [ -f "$MANIFEST_FILE" ]; then
    while IFS= read -r OLD_SCRIPT; do
      [ -n "$OLD_SCRIPT" ] || continue
      if ! is_safe_entry_name "$OLD_SCRIPT"; then
        echo "  skipping unsafe script manifest entry: $OLD_SCRIPT" >&2
        continue
      fi

      if ! grep -qxF "$OLD_SCRIPT" "$TEMP_MANIFEST"; then
        rm -f -- "$DEST_DIR/$OLD_SCRIPT"
      fi
    done < "$MANIFEST_FILE"
  fi

  chmod 0644 "$TEMP_MANIFEST"
  mv -f -- "$TEMP_MANIFEST" "$MANIFEST_FILE"
}

sync_agent_files() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"
  local MODE="$3"
  local MANIFEST_FILE="$DEST_DIR/.sync_agents_manifest"
  local TEMP_MANIFEST
  local SOURCE_FILE
  local AGENT_NAME
  local TEMP_FILE
  local CONVERTER

  mkdir -p "$DEST_DIR"
  TEMP_MANIFEST="$(mktemp "$DEST_DIR/.sync_agents_manifest.XXXXXX")"

  for SOURCE_FILE in "$SOURCE_DIR"/*.md; do
    [ -f "$SOURCE_FILE" ] || continue

    AGENT_NAME="$(basename "$SOURCE_FILE")"

    if [ "$MODE" = "copy" ]; then
      cp "$SOURCE_FILE" "$DEST_DIR/$AGENT_NAME"
      chmod 0644 "$DEST_DIR/$AGENT_NAME"
    else
      case "$MODE" in
        claude)
          CONVERTER="$BASE_DIR/scripts/agent_to_claude.mjs"
          ;;
        antigravity)
          CONVERTER="$BASE_DIR/scripts/agent_to_antigravity.mjs"
          ;;
        *)
          record_error "unknown agent sync mode '$MODE' for $DEST_DIR"
          rm -f -- "$TEMP_MANIFEST"
          return 1
          ;;
      esac

      # Write to a temporary file first so a failed conversion never truncates
      # the definition that is already in place.
      TEMP_FILE="$(mktemp "$DEST_DIR/.agent_sync.XXXXXX")"

      if ! node "$CONVERTER" "$SOURCE_FILE" > "$TEMP_FILE"; then
        record_error "failed to convert $AGENT_NAME ($MODE)"
        rm -f -- "$TEMP_FILE"
        if [ -f "$DEST_DIR/$AGENT_NAME" ]; then
          printf '%s\n' "$AGENT_NAME" >> "$TEMP_MANIFEST"
        fi
        continue
      fi

      chmod 0644 "$TEMP_FILE"
      mv -f -- "$TEMP_FILE" "$DEST_DIR/$AGENT_NAME"
    fi

    printf '%s\n' "$AGENT_NAME" >> "$TEMP_MANIFEST"
    echo "  synced ${DEST_DIR%/}/$AGENT_NAME"
  done

  sort -u -o "$TEMP_MANIFEST" "$TEMP_MANIFEST"

  if [ -f "$MANIFEST_FILE" ]; then
    while IFS= read -r OLD_AGENT; do
      [ -n "$OLD_AGENT" ] || continue
      if ! is_safe_entry_name "$OLD_AGENT"; then
        echo "  skipping unsafe manifest entry: $OLD_AGENT" >&2
        continue
      fi

      if ! grep -qxF "$OLD_AGENT" "$TEMP_MANIFEST"; then
        rm -f -- "$DEST_DIR/$OLD_AGENT"
        echo "  removed ${DEST_DIR%/}/$OLD_AGENT"
      fi
    done < "$MANIFEST_FILE"
  fi

  chmod 0644 "$TEMP_MANIFEST"
  mv -f -- "$TEMP_MANIFEST" "$MANIFEST_FILE"
}

# Agent subagent directories and the format each one expects.
# The canonical definitions in agents/ use the OpenCode V2 format.
AGENT_SUBDIR_DIRS=(
  "$HOME/.config/opencode/agents|copy"
  "$HOME/.claude/agents|claude"
  "$HOME/.gemini/config/agents|antigravity"
)

# Codex reads TOML custom agents and receives only the agents that
# agents/models.yml pins to a Codex model.
sync_codex_agents() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"
  local MANIFEST_FILE="$DEST_DIR/.sync_agents_manifest"
  local TEMP_MANIFEST
  local AGENT_NAMES
  local AGENT_NAME
  local TEMP_FILE

  if ! AGENT_NAMES="$(node "$BASE_DIR/scripts/agent_to_codex.mjs" --list "$SOURCE_DIR")"; then
    record_error "failed to read the Codex model pins"
    return 1
  fi

  mkdir -p "$DEST_DIR"
  TEMP_MANIFEST="$(mktemp "$DEST_DIR/.sync_agents_manifest.XXXXXX")"

  while IFS= read -r AGENT_NAME; do
    [ -n "$AGENT_NAME" ] || continue

    if ! is_safe_entry_name "$AGENT_NAME" || [ ! -f "$SOURCE_DIR/$AGENT_NAME.md" ]; then
      record_error "Codex pin for '$AGENT_NAME' has no agents/$AGENT_NAME.md"
      continue
    fi

    TEMP_FILE="$(mktemp "$DEST_DIR/.agent_sync.XXXXXX")"

    if ! node "$BASE_DIR/scripts/agent_to_codex.mjs" "$SOURCE_DIR/$AGENT_NAME.md" > "$TEMP_FILE"; then
      record_error "failed to convert $AGENT_NAME.md (codex)"
      rm -f -- "$TEMP_FILE"
      if [ -f "$DEST_DIR/$AGENT_NAME.toml" ]; then
        printf '%s\n' "$AGENT_NAME.toml" >> "$TEMP_MANIFEST"
      fi
      continue
    fi

    chmod 0644 "$TEMP_FILE"
    mv -f -- "$TEMP_FILE" "$DEST_DIR/$AGENT_NAME.toml"
    printf '%s\n' "$AGENT_NAME.toml" >> "$TEMP_MANIFEST"
    echo "  synced ${DEST_DIR%/}/$AGENT_NAME.toml"
  done <<< "$AGENT_NAMES"

  sort -u -o "$TEMP_MANIFEST" "$TEMP_MANIFEST"

  if [ -f "$MANIFEST_FILE" ]; then
    while IFS= read -r OLD_AGENT; do
      [ -n "$OLD_AGENT" ] || continue
      if ! is_safe_entry_name "$OLD_AGENT"; then
        echo "  skipping unsafe manifest entry: $OLD_AGENT" >&2
        continue
      fi

      if ! grep -qxF "$OLD_AGENT" "$TEMP_MANIFEST"; then
        rm -f -- "$DEST_DIR/$OLD_AGENT"
        echo "  removed ${DEST_DIR%/}/$OLD_AGENT"
      fi
    done < "$MANIFEST_FILE"
  fi

  chmod 0644 "$TEMP_MANIFEST"
  mv -f -- "$TEMP_MANIFEST" "$MANIFEST_FILE"
}

# Installed agents that have no subagent directory.
AGENTS_WITHOUT_SUBDIRS=(
  "$HOME/.pi/agent|pi"
  "$HOME/.dsh|dsh"
)

sync_agents() {
  local SOURCE_DIR="$BASE_DIR/agents"
  local ENTRY
  local AGENT_SUBDIR_DIR
  local AGENT_SUBDIR_MODE
  local AGENT_HOME
  local AGENT_NAME

  if [ ! -d "$SOURCE_DIR" ]; then
    echo "No agents directory found."
    return 0
  fi

  for ENTRY in "${AGENT_SUBDIR_DIRS[@]}"; do
    AGENT_SUBDIR_DIR="${ENTRY%%|*}"
    AGENT_SUBDIR_MODE="${ENTRY##*|}"

    if [ ! -d "$(dirname "$AGENT_SUBDIR_DIR")" ]; then
      continue
    fi

    if [ "$AGENT_SUBDIR_MODE" != "copy" ] && ! command -v node >/dev/null 2>&1; then
      record_error "skipped $AGENT_SUBDIR_DIR (node is not installed)"
      continue
    fi

    echo "Syncing agents to $AGENT_SUBDIR_DIR..."
    sync_agent_files "$SOURCE_DIR" "$AGENT_SUBDIR_DIR" "$AGENT_SUBDIR_MODE" || true
  done

  if [ -d "$HOME/.codex" ]; then
    if command -v node >/dev/null 2>&1; then
      echo "Syncing agents to $HOME/.codex/agents..."
      sync_codex_agents "$SOURCE_DIR" "$HOME/.codex/agents" || true
    else
      record_error "skipped $HOME/.codex/agents (node is not installed)"
    fi
  fi

  for ENTRY in "${AGENTS_WITHOUT_SUBDIRS[@]}"; do
    AGENT_HOME="${ENTRY%%|*}"
    AGENT_NAME="${ENTRY##*|}"

    if [ -d "$AGENT_HOME" ]; then
      echo "  skipped $AGENT_NAME (no markdown subagent directory)"
    fi
  done
}

# Only sync agents that are installed, detected by their config dir existing.
# Each entry is the AGENTS.md/CLAUDE.md file inside that agent's config dir.
AGENT_FILES=(
  "$HOME/.codex/AGENTS.md"
  "$HOME/.config/opencode/AGENTS.md"
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.gemini/config/AGENTS.md"
  "$HOME/.pi/agent/AGENTS.md"
  "$HOME/.dsh/AGENTS.md"
)

# Sync global AGENTS.md
echo "Syncing global AGENTS.md..."
for AGENT_FILE in "${AGENT_FILES[@]}"; do
  AGENT_DIR="$(dirname "$AGENT_FILE")"

  if [ -d "$AGENT_DIR" ]; then
    cp "$BASE_DIR/global/AGENTS.md" "$AGENT_FILE"
    echo "  synced $AGENT_FILE"
  else
    echo "  skipped $AGENT_FILE (no $AGENT_DIR)"
  fi
done

echo "Syncing skills..."

SKILLS_DIR="$BASE_DIR/skills"

if [ -d "$SKILLS_DIR" ]; then
  for AGENT_FILE in "${AGENT_FILES[@]}"; do
    AGENT_DIR="$(dirname "$AGENT_FILE")"

    if [ -d "$AGENT_DIR" ]; then
      sync_skills "$SKILLS_DIR" "$AGENT_DIR/skills"
    fi
  done

  echo "Syncing skill scripts to $HOME/.local/bin..."
  sync_skill_scripts "$SKILLS_DIR" "$HOME/.local/bin"
else
  echo "No skills directory found at $SKILLS_DIR."
fi

echo "Syncing agents..."

sync_agents

if [ "$SYNC_ERRORS" -gt 0 ]; then
  echo "Sync finished with $SYNC_ERRORS error(s)." >&2
  exit 1
fi

echo "Sync complete."
