#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sync_skills() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"
  local MANIFEST_FILE="$DEST_DIR/.sync_config_manifest"

  mkdir -p "$DEST_DIR"

  if [ -f "$MANIFEST_FILE" ]; then
    while IFS= read -r SKILL_NAME; do
      if ! is_safe_entry_name "$SKILL_NAME"; then
        echo "Skipping unsafe manifest entry: $SKILL_NAME"
        continue
      fi

      if [ ! -e "$SOURCE_DIR/$SKILL_NAME" ]; then
        rm -rf -- "$DEST_DIR/$SKILL_NAME"
      fi
    done < "$MANIFEST_FILE"
  fi

  find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -exec rsync -a --delete {} "$DEST_DIR" \;
  find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort > "$MANIFEST_FILE"
}

sync_skill_scripts() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"
  local MANIFEST_FILE="$DEST_DIR/.sync_config_scripts_manifest"

  mkdir -p "$DEST_DIR"

  if [ -f "$MANIFEST_FILE" ]; then
    while IFS= read -r SCRIPT_NAME; do
      if ! is_safe_entry_name "$SCRIPT_NAME"; then
        echo "Skipping unsafe script manifest entry: $SCRIPT_NAME"
        continue
      fi

      if ! find "$SOURCE_DIR" -mindepth 3 -maxdepth 3 -path '*/scripts/*' -type f ! -name '.*' -perm -u+x -name "$SCRIPT_NAME" | grep -q .; then
        rm -f -- "$DEST_DIR/$SCRIPT_NAME"
      fi
    done < "$MANIFEST_FILE"
  fi

  find "$SOURCE_DIR" -mindepth 3 -maxdepth 3 -path '*/scripts/*' -type f ! -name '.*' -perm -u+x -exec install -m 0755 {} "$DEST_DIR/" \;
  find "$SOURCE_DIR" -mindepth 3 -maxdepth 3 -path '*/scripts/*' -type f ! -name '.*' -perm -u+x -exec basename {} \; | sort -u > "$MANIFEST_FILE"
}

sync_agent_files() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"
  local MODE="$3"
  local MANIFEST_FILE="$DEST_DIR/.sync_agents_manifest"

  mkdir -p "$DEST_DIR"

  if [ -f "$MANIFEST_FILE" ]; then
    while IFS= read -r AGENT_NAME; do
      if ! is_safe_entry_name "$AGENT_NAME"; then
        echo "Skipping unsafe manifest entry: $AGENT_NAME"
        continue
      fi

      if [ ! -e "$SOURCE_DIR/$AGENT_NAME" ]; then
        rm -f -- "$DEST_DIR/$AGENT_NAME"
      fi
    done < "$MANIFEST_FILE"
  fi

  for SOURCE_FILE in "$SOURCE_DIR"/*.md; do
    [ -f "$SOURCE_FILE" ] || continue

    AGENT_NAME="$(basename "$SOURCE_FILE")"

    if [ "$MODE" = "convert" ]; then
      # Write to a temporary file first so a failed conversion never truncates
      # the definition that is already in place.
      TEMP_FILE="$(mktemp "$DEST_DIR/.agent_sync.XXXXXX")"

      if ! ruby "$BASE_DIR/scripts/agent_to_claude.rb" "$SOURCE_FILE" > "$TEMP_FILE"; then
        echo "  failed to convert $AGENT_NAME" >&2
        rm -f -- "$TEMP_FILE"
        continue
      fi

      mv -f -- "$TEMP_FILE" "$DEST_DIR/$AGENT_NAME"
    else
      cp "$SOURCE_FILE" "$DEST_DIR/$AGENT_NAME"
    fi

    echo "  synced ${DEST_DIR%/}/$AGENT_NAME"
  done

  find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -name '*.md' -exec basename {} \; | sort > "$MANIFEST_FILE"
}

# Agent subagent directories and the format each one expects.
# The canonical definitions in agents/ use the OpenCode V2 format.
# "copy" keeps that format, "convert" rewrites the frontmatter for Claude Code.
AGENT_SUBDIR_DIRS=(
  "$HOME/.config/opencode/agents|copy"
  "$HOME/.claude/agents|convert"
)

# Codex reads TOML custom agents and receives only the agents that
# agents/models.yml pins to a Codex model.
sync_codex_agents() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"
  local MANIFEST_FILE="$DEST_DIR/.sync_agents_manifest"
  local AGENT_NAMES

  if ! AGENT_NAMES="$(ruby "$BASE_DIR/scripts/agent_to_codex.rb" --list "$SOURCE_DIR")"; then
    echo "  failed to read the Codex model pins" >&2
    return 1
  fi

  mkdir -p "$DEST_DIR"

  if [ -f "$MANIFEST_FILE" ]; then
    while IFS= read -r AGENT_FILE; do
      if ! is_safe_entry_name "$AGENT_FILE"; then
        echo "Skipping unsafe manifest entry: $AGENT_FILE"
        continue
      fi

      if ! printf '%s\n' "$AGENT_NAMES" | grep -qxF "${AGENT_FILE%.toml}"; then
        rm -f -- "$DEST_DIR/$AGENT_FILE"
      fi
    done < "$MANIFEST_FILE"
  fi

  : > "$MANIFEST_FILE"

  while IFS= read -r AGENT_NAME; do
    [ -n "$AGENT_NAME" ] || continue

    if ! is_safe_entry_name "$AGENT_NAME" || [ ! -f "$SOURCE_DIR/$AGENT_NAME.md" ]; then
      echo "  skipped Codex pin for $AGENT_NAME (no agents/$AGENT_NAME.md)" >&2
      continue
    fi

    echo "$AGENT_NAME.toml" >> "$MANIFEST_FILE"
    TEMP_FILE="$(mktemp "$DEST_DIR/.agent_sync.XXXXXX")"

    if ! ruby "$BASE_DIR/scripts/agent_to_codex.rb" "$SOURCE_DIR/$AGENT_NAME.md" > "$TEMP_FILE"; then
      echo "  failed to convert $AGENT_NAME.md" >&2
      rm -f -- "$TEMP_FILE"
      continue
    fi

    mv -f -- "$TEMP_FILE" "$DEST_DIR/$AGENT_NAME.toml"
    echo "  synced ${DEST_DIR%/}/$AGENT_NAME.toml"
  done <<< "$AGENT_NAMES"
}

# Installed agents that have no subagent directory.
AGENTS_WITHOUT_SUBDIRS=(
  "$HOME/.pi/agent|pi"
  "$HOME/.omp/agent|omp"
  "$HOME/.dsh|dsh"
)

sync_agents() {
  local SOURCE_DIR="$BASE_DIR/agents"

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

    if [ "$AGENT_SUBDIR_MODE" = "convert" ] && ! command -v ruby >/dev/null 2>&1; then
      echo "  skipped $AGENT_SUBDIR_DIR (ruby is not installed)"
      continue
    fi

    echo "Syncing agents to $AGENT_SUBDIR_DIR..."
    sync_agent_files "$SOURCE_DIR" "$AGENT_SUBDIR_DIR" "$AGENT_SUBDIR_MODE"
  done

  if [ -d "$HOME/.codex" ]; then
    if command -v ruby >/dev/null 2>&1; then
      echo "Syncing agents to $HOME/.codex/agents..."
      sync_codex_agents "$SOURCE_DIR" "$HOME/.codex/agents"
    else
      echo "  skipped $HOME/.codex/agents (ruby is not installed)"
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

# Only sync agents that are installed, detected by their config dir existing.
# Each entry is the AGENTS.md/CLAUDE.md file inside that agent's config dir.
AGENT_FILES=(
  "$HOME/.codex/AGENTS.md"
  "$HOME/.config/opencode/AGENTS.md"
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.pi/agent/AGENTS.md"
  "$HOME/.omp/agent/AGENTS.md"
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
      sync_skills "$SKILLS_DIR" "$AGENT_DIR/skills/"
    fi
  done

  echo "Syncing skill scripts to $HOME/.local/bin..."
  sync_skill_scripts "$SKILLS_DIR" "$HOME/.local/bin"
else
  echo "No skills directory found at $SKILLS_DIR."
fi

echo "Syncing agents..."

sync_agents

echo "Sync complete."
