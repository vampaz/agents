# Tools for agents

This repository is the single source of truth for the shared agent configuration.

| Path | Contents |
| --- | --- |
| `global/AGENTS.md` | Instructions shared by every agent |
| `agents/` | Subagent definitions in the OpenCode V2 format |
| `skills/` | Skills shared by every agent |
| `scripts/` | Helpers for sync and skill maintenance |

Run `./sync_config.sh` to copy the shared files into the configuration folder of every installed agent. The script syncs the instructions and the skills to every agent, and the subagent definitions to OpenCode and Claude Code.

Google Chrome's [WebMCP skill](skills/build-webmcp-tools/SKILL.md) is included with its reference guides and evaluation fixtures. See its [upstream record](skills/build-webmcp-tools/UPSTREAM.md) for the source revision, license, and update instructions.

Google Chrome's [Modern Web Guidance](skills/modern-web-guidance/SKILL.md) and [Chrome Extensions](skills/chrome-extensions/SKILL.md) skills are included. See their upstream records for the source version, license, and update instructions. Run `scripts/update-modern-web-guidance.sh` to refresh both from the published package.
