# Tools for agents

This repository is the single source of truth for the shared agent configuration across installed harnesses (`codex`, `opencode`, `claude`, `antigravity`, `pi`, and `dsh`).

| Path | Contents |
| --- | --- |
| `global/AGENTS.md` | Instructions shared by every agent |
| `agents/` | Subagent definitions in OpenCode V2 format plus `models.yml` pins |
| `skills/` | Skills shared by every agent |
| `scripts/` | Zero-dependency Node.js ESM and Bash helpers for sync, validation, and updates |
| `notes/` | Standalone design notes and PRDs (not synced) |

## Usage

Run `./sync_config.sh` to copy shared files into the configuration folder of every installed harness:

- Copies `global/AGENTS.md` to every installed harness (`CLAUDE.md` for Claude Code, `AGENTS.md` for the rest, including `~/.gemini/config/AGENTS.md` for Antigravity).
- Syncs `skills/` to every installed harness (excluding `evals/` directories).
- Syncs `agents/` to OpenCode (unchanged), Claude Code (`scripts/agent_to_claude.mjs`), Antigravity (`scripts/agent_to_antigravity.mjs`), and Codex (`scripts/agent_to_codex.mjs`, for agents pinned in `agents/models.yml`).

Run `./scripts/verify.sh` to check script syntax, run unit tests (`scripts/scripts.spec.mjs`), validate agent definitions and skills, and confirm instruction parity across every installed harness.

## Vendored Skills

| Skill | Upstream / Source | Update Method |
| --- | --- | --- |
| `build-webmcp-tools` | [UPSTREAM.md](skills/build-webmcp-tools/UPSTREAM.md) (GoogleChromeLabs/webmcp-tools) | Manual copy from reviewed revision |
| `modern-web-guidance` | [UPSTREAM.md](skills/modern-web-guidance/UPSTREAM.md) (GoogleChrome/modern-web-guidance) | `scripts/update-modern-web-guidance.sh` |
| `chrome-extensions` | [UPSTREAM.md](skills/chrome-extensions/UPSTREAM.md) (GoogleChrome/modern-web-guidance) | `scripts/update-modern-web-guidance.sh` |
| `cloudflare`, `agents-sdk`, `durable-objects`, `workers-best-practices`, `wrangler` | Cloudflare skills suite | Refresh from upstream Cloudflare skills |
| `typesafe-ai`, `ui-design`, `ux` | External reference skills | Refresh manually as needed |
