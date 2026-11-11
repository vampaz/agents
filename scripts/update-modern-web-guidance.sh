#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$BASE_DIR/skills"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading modern-web-guidance..."
npm pack modern-web-guidance@latest --silent --pack-destination "$TMP_DIR" >/dev/null

TARBALL="$(find "$TMP_DIR" -maxdepth 1 -name 'modern-web-guidance-*.tgz' -print -quit)"

if [ -z "$TARBALL" ]; then
  echo "Could not find the downloaded package." >&2
  exit 1
fi

tar -xzf "$TARBALL" -C "$TMP_DIR"
PACKAGE_DIR="$TMP_DIR/package"

VERSION="$(node -p "require('$PACKAGE_DIR/package.json').version")"
MWG_SKILL_VERSION="$(tr -d '[:space:]' < "$PACKAGE_DIR/skills/modern-web-guidance/skill-version.txt")"
CHROME_SKILL_VERSION="$(tr -d '[:space:]' < "$PACKAGE_DIR/skills/chrome-extensions/skill-version.txt")"
TODAY="$(date +%Y-%m-%d)"

echo "Updating modern-web-guidance@$VERSION..."

mkdir -p "$SKILLS_DIR/modern-web-guidance" "$SKILLS_DIR/chrome-extensions"

cp "$PACKAGE_DIR/skills/modern-web-guidance/SKILL.md" "$SKILLS_DIR/modern-web-guidance/SKILL.md"
cp "$PACKAGE_DIR/LICENSE" "$SKILLS_DIR/modern-web-guidance/LICENSE"
cp "$PACKAGE_DIR/LICENSE" "$SKILLS_DIR/chrome-extensions/LICENSE"

rsync -a --delete \
  --exclude 'UPSTREAM.md' \
  --exclude 'LICENSE' \
  "$PACKAGE_DIR/skills/chrome-extensions/" "$SKILLS_DIR/chrome-extensions/"

cat > "$SKILLS_DIR/modern-web-guidance/UPSTREAM.md" <<EOF
# Upstream source

- Source: [GoogleChrome/modern-web-guidance](https://github.com/GoogleChrome/modern-web-guidance), \`skills/modern-web-guidance\`.
- Package: \`modern-web-guidance@$VERSION\`.
- Skill version: \`$MWG_SKILL_VERSION\`.
- Updated on: $TODAY.
- License: [Apache-2.0](LICENSE).

Only the upstream \`SKILL.md\` is copied; \`LICENSE\` and this record are added locally. The skill runs \`npx -y modern-web-guidance@latest\`, so the CLI and its 209 guides come from the published package. The upstream folder also contains \`guides/\`, \`gen/\`, and the CLI entry points; they are intentionally excluded to avoid copying 16 MB into every agent.

Shared and repository instructions continue to govern package commands, network use, and required validation when applying this skill.

To update, run \`scripts/update-modern-web-guidance.sh\` from the repository root, review the diff, run the completion gate, then run \`./sync_config.sh\` and verify the installed copies.
EOF

cat > "$SKILLS_DIR/chrome-extensions/UPSTREAM.md" <<EOF
# Upstream source

- Source: [GoogleChrome/modern-web-guidance](https://github.com/GoogleChrome/modern-web-guidance), \`skills/chrome-extensions\`.
- Package: \`modern-web-guidance@$VERSION\`.
- Skill version: \`$CHROME_SKILL_VERSION\`.
- Updated on: $TODAY.
- License: [Apache-2.0](LICENSE).

\`SKILL.md\`, \`references/\`, and \`skill-version.txt\` are copied unchanged. The skill is part of the Modern Web Guidance package but is installed separately because it covers Chrome extension development and Web Store publishing rather than web page guidance.

Shared and repository instructions continue to govern package commands, dependency choices, and required validation when applying this skill.

To update, run \`scripts/update-modern-web-guidance.sh\` from the repository root, review the diff, run the completion gate, then run \`./sync_config.sh\` and verify the installed copies.
EOF

echo "Updated to modern-web-guidance@$VERSION."
echo "Next: review the diff, then run ./sync_config.sh."
