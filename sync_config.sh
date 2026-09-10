#!/bin/bash

sync_skills() {
  local SOURCE_DIR="$1"
  local DEST_DIR="$2"
  local MANIFEST_FILE="$DEST_DIR/.sync_config_manifest"

  mkdir -p "$DEST_DIR"

  if [ -f "$MANIFEST_FILE" ]; then
    while IFS= read -r SKILL_NAME; do
      if ! is_safe_skill_name "$SKILL_NAME"; then
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

is_safe_skill_name() {
  local SKILL_NAME="$1"

  if [ -z "$SKILL_NAME" ] || [ "$SKILL_NAME" = "." ] || [ "$SKILL_NAME" = ".." ]; then
    return 1
  fi

  case "$SKILL_NAME" in
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
)

# Sync AGENTS.md
echo "Syncing AGENTS.md..."
for AGENT_FILE in "${AGENT_FILES[@]}"; do
  AGENT_DIR="$(dirname "$AGENT_FILE")"

  if [ -d "$AGENT_DIR" ]; then
    cp AGENTS.md "$AGENT_FILE"
    echo "  synced $AGENT_FILE"
  else
    echo "  skipped $AGENT_FILE (no $AGENT_DIR)"
  fi
done

echo "Syncing skills..."

SKILLS_DIR=""
if [ -d "skills" ]; then
  SKILLS_DIR="skills"
elif [ -d "skils" ]; then
  SKILLS_DIR="skils"
fi

if [ -n "$SKILLS_DIR" ]; then
  for AGENT_FILE in "${AGENT_FILES[@]}"; do
    AGENT_DIR="$(dirname "$AGENT_FILE")"

    if [ -d "$AGENT_DIR" ]; then
      sync_skills "$SKILLS_DIR" "$AGENT_DIR/skills/"
    fi
  done
else
  echo "No skills directory found (skills/ or skils/)."
fi

echo "Sync complete."
