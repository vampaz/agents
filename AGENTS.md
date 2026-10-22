# Repository Instructions

Follow the shared instructions in `global/AGENTS.md`, with the repository-specific rules below.

## Git Policy

- Work directly on `master` in this repository. Do not create branches unless the user explicitly requests one.
- The user authorizes commits and pushes to `master` after the mandatory completion gate passes.
- This authorization overrides the protected master policy in the shared instructions for this repository only.

## Synchronization

- This `AGENTS.md` applies only to this repository. Never synchronize it to agent configuration folders or other repositories.
- Synchronize `global/AGENTS.md` to agent configuration folders using `sync_config.sh`.

## Shared Folders

This repository is the single source of truth for the shared agent configuration. `sync_config.sh` copies it into the configuration folder of every installed agent.

| Folder | Contents | Destination |
| --- | --- | --- |
| `global/AGENTS.md` | Shared instructions | The `AGENTS.md` or `CLAUDE.md` file of every installed agent |
| `skills/` | Skills | The `skills/` folder of every installed agent |
| `agents/` | Subagent definitions | The `agents/` folder of OpenCode and Claude Code |
| `scripts/` | Helpers used by `sync_config.sh` | Not synced |

Never edit the copies inside the agent configuration folders. Edit the source here and run `sync_config.sh`.

After editing a shared file, verify the sync:

1. Run `bash -n sync_config.sh` when the script changed.
2. Run `./sync_config.sh`.
3. Compare one destination, for example `diff global/AGENTS.md ~/.config/opencode/AGENTS.md`.

## Subagent Definitions

The definitions in `agents/` use the OpenCode V2 format. `sync_config.sh` copies them unchanged to OpenCode and converts them to the Claude Code format with `scripts/agent_to_claude.rb`. Codex, pi, omp, and dsh have no markdown subagent folder, so the script skips them.
