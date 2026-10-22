# Tools for agents

This repository is the single source of truth for the shared agent configuration.

| Path | Contents |
| --- | --- |
| `global/AGENTS.md` | Instructions shared by every agent |
| `agents/` | Subagent definitions in the OpenCode V2 format |
| `skills/` | Skills shared by every agent |
| `scripts/` | Helpers used by `sync_config.sh` |

Run `./sync_config.sh` to copy the shared files into the configuration folder of every installed agent. The script syncs the instructions and the skills to every agent, and the subagent definitions to OpenCode and Claude Code.
