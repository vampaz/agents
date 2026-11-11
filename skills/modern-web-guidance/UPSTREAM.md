# Upstream source

- Source: [GoogleChrome/modern-web-guidance](https://github.com/GoogleChrome/modern-web-guidance), `skills/modern-web-guidance`.
- Package: `modern-web-guidance@1.0.0`.
- Skill version: `2026_11_09-5bcc021b`.
- Updated on: 2026-11-11.
- License: [Apache-2.0](LICENSE).

Only the upstream `SKILL.md` is copied; `LICENSE` and this record are added locally. The skill runs `npx -y modern-web-guidance@latest`, so the CLI and its 209 guides come from the published package. The upstream folder also contains `guides/`, `gen/`, and the CLI entry points; they are intentionally excluded to avoid copying 16 MB into every agent.

Shared and repository instructions continue to govern package commands, network use, and required validation when applying this skill.

To update, run `scripts/update-modern-web-guidance.sh` from the repository root, review the diff, run the completion gate, then run `./sync_config.sh` and verify the installed copies.
