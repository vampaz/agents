#!/bin/bash

# Sync AGENTS.md
echo "Syncing AGENTS.md..."
cp AGENTS.md "$HOME/.codex/"
cp AGENTS.md "$HOME/.config/opencode/"
cp AGENTS.md "$HOME/.claude/CLAUDE.md"

# Sync commands
echo "Syncing commands..."

cp -r commands/* "$HOME/.codex/prompts/"
cp -r commands/* "$HOME/.config/opencode/command/"
cp -r commands/* "$HOME/.claude/commands/"

echo "Syncing skills..."

SKILLS_DIR=""
if [ -d "skills" ]; then
  SKILLS_DIR="skills"
elif [ -d "skils" ]; then
  SKILLS_DIR="skils"
fi

if [ -n "$SKILLS_DIR" ]; then
  mkdir -p "$HOME/.codex/skills/"
  cp -r "$SKILLS_DIR"/* "$HOME/.codex/skills/"
else
  echo "No skills directory found (skills/ or skils/)."
fi

echo "Sync complete."
