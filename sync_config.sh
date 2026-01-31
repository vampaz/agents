#!/bin/bash

# Sync AGENTS.md
echo "Syncing AGENTS.md..."
mkdir -p "$HOME/.codex/" "$HOME/.config/opencode/" "$HOME/.claude/" "$HOME/.gemini/"
cp AGENTS.md "$HOME/.codex/"
cp AGENTS.md "$HOME/.config/opencode/"
cp AGENTS.md "$HOME/.claude/CLAUDE.md"
cp AGENTS.md "$HOME/.gemini/GEMINI.MD"

# Sync commands
echo "Syncing commands..."

mkdir -p "$HOME/.codex/prompts/" "$HOME/.config/opencode/commands/" "$HOME/.claude/commands/" "$HOME/.gemini/commands/"
cp -r commands/* "$HOME/.codex/prompts/"
cp -r commands/* "$HOME/.config/opencode/commands/"
cp -r commands/* "$HOME/.claude/commands/"
cp -r commands/* "$HOME/.gemini/commands/"

echo "Syncing skills..."

SKILLS_DIR=""
if [ -d "skills" ]; then
  SKILLS_DIR="skills"
elif [ -d "skils" ]; then
  SKILLS_DIR="skils"
fi

if [ -n "$SKILLS_DIR" ]; then
  mkdir -p "$HOME/.codex/skills/" "$HOME/.opencode/skills/" "$HOME/.claude/skills/" "$HOME/.gemini/skills/"
  cp -r "$SKILLS_DIR"/* "$HOME/.codex/skills/"
  cp -r "$SKILLS_DIR"/* "$HOME/.config/opencode/skills/"
  cp -r "$SKILLS_DIR"/* "$HOME/.claude/skills/"
  cp -r "$SKILLS_DIR"/* "$HOME/.gemini/skills/"
else
  echo "No skills directory found (skills/ or skils/)."
fi

echo "Sync complete."
