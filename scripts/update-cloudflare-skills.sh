#!/bin/bash

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$BASE_DIR/skills"
UPSTREAM_REPO="https://github.com/cloudflare/skills.git"
SKILLS=(
  cloudflare
  workers-best-practices
  durable-objects
  agents-sdk
)

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning cloudflare/skills..."
git clone --quiet --depth 1 "$UPSTREAM_REPO" "$TMP_DIR/repo"

REV="$(git -C "$TMP_DIR/repo" rev-parse HEAD)"
COMMIT_DATE="$(git -C "$TMP_DIR/repo" show -s --format=%cs HEAD)"
TODAY="$(date +%Y-%m-%d)"

echo "Updating Cloudflare skills to $REV ($COMMIT_DATE)..."

for SKILL in "${SKILLS[@]}"; do
  SRC="$TMP_DIR/repo/skills/$SKILL"
  DEST="$SKILLS_DIR/$SKILL"

  if [ ! -d "$SRC" ]; then
    echo "Upstream skill not found: $SKILL" >&2
    exit 1
  fi

  mkdir -p "$DEST"
  rsync -a --delete \
    --exclude 'UPSTREAM.md' \
    --exclude 'LICENSE' \
    "$SRC/" "$DEST/"

  if [ -f "$TMP_DIR/repo/LICENSE" ]; then
    cp "$TMP_DIR/repo/LICENSE" "$DEST/LICENSE"
  fi

  cat > "$DEST/UPSTREAM.md" <<EOF
# Upstream source

- Source: [cloudflare/skills](https://github.com/cloudflare/skills/tree/$REV/skills/$SKILL), \`skills/$SKILL\`.
- Revision: \`$REV\` ($COMMIT_DATE).
- Updated on: $TODAY.
- License: [Apache-2.0](LICENSE).

Copied unchanged from upstream; \`LICENSE\` and this record are added locally.

Shared and repository instructions continue to govern package commands, network use, deployment policy, and required validation when applying this skill.

To update, run \`scripts/update-cloudflare-skills.sh\` from the repository root, review the diff, run the completion gate, then run \`./sync_config.sh\` and \`./scripts/verify.sh\`.
EOF
done

echo "Updated ${#SKILLS[@]} Cloudflare skills to $REV."
echo "Next: review the diff, then run ./sync_config.sh and ./scripts/verify.sh."
