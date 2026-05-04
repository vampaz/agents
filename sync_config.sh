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

# Sync AGENTS.md
echo "Syncing AGENTS.md..."
mkdir -p "$HOME/.codex/" "$HOME/.config/opencode/" "$HOME/.claude/" "$HOME/.pi/agent/"
cp AGENTS.md "$HOME/.codex/"
cp AGENTS.md "$HOME/.config/opencode/"
cp AGENTS.md "$HOME/.claude/CLAUDE.md"
cp AGENTS.md "$HOME/.pi/agent/AGENTS.md"

echo "Syncing skills..."

SKILLS_DIR=""
if [ -d "skills" ]; then
  SKILLS_DIR="skills"
elif [ -d "skils" ]; then
  SKILLS_DIR="skils"
fi

if [ -n "$SKILLS_DIR" ]; then
  for DEST_DIR in "$HOME/.codex/skills/" "$HOME/.config/opencode/skills/" "$HOME/.claude/skills/" "$HOME/.pi/agent/skills/"; do
    sync_skills "$SKILLS_DIR" "$DEST_DIR"
  done
else
  echo "No skills directory found (skills/ or skils/)."
fi

echo "Sync complete."
