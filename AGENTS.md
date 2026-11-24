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

This repository is the single source of truth for the shared agent configuration. `sync_config.sh` copies it into the configuration folder of every installed agent (`codex`, `opencode`, `claude`, `antigravity`, `pi`, and `dsh`).

| Folder | Contents | Destination |
| --- | --- | --- |
| `global/AGENTS.md` | Shared instructions | The `AGENTS.md` or `CLAUDE.md` file of every installed agent |
| `skills/` | Skills | The `skills/` folder of every installed agent |
| `agents/` | Subagent definitions | The `agents/` folder of OpenCode, Claude Code, Codex, and Antigravity |
| `scripts/` | Node.js ESM and Bash helpers | Not synced |

Never edit the copies inside the agent configuration folders. Edit the source here and run `sync_config.sh`.

After editing a shared file or script, run the sync and verification suite:

1. Run `./sync_config.sh`.
2. Run `./scripts/verify.sh` (syntax checks for Bash and Node.js ESM scripts, unit tests, agent/skill validation across source and installed directories, and instruction parity across every installed harness).

## Subagent Definitions

The definitions in `agents/` use the OpenCode V2 format. `sync_config.sh` copies them unchanged to OpenCode, converts them to Claude Code with `scripts/agent_to_claude.mjs`, and converts them to Antigravity with `scripts/agent_to_antigravity.mjs`. `agents/models.yml` pins models for harnesses that do not use OpenCode model names. Codex receives only the agents with a `codex` pin, converted to TOML with `scripts/agent_to_codex.mjs`. `pi` and `dsh` have no subagent folder, so the script skips them.
