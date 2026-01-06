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

echo "Sync complete."
