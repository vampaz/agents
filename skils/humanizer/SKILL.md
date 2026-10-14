---
name: humanizer
description: Rewrite AI-sounding text into natural, human-sounding text using the local LM Studio model `humanizer-12b-optiq` via the `humanize` CLI. Load whenever the user asks to humanize text, rewrite AI-generated prose so it reads like a person wrote it, or remove language-model phrasing.
---

# Humanizer (`humanizer-12b-optiq`)

Use the local `humanize` CLI script to rewrite AI-sounding prose into natural, human-sounding text while preserving every fact, number, unit, date, name, and quotation unchanged.

## How It Works

The `humanize` command (installed in `~/.local/bin/humanize` and bundled at `scripts/humanize` inside this skill directory) automatically:

1. Checks whether the LM Studio server (`http://127.0.0.1:1234`) is running and starts it with `lms server start` if needed.
2. Checks whether `humanizer-12b-optiq` is loaded and loads it with `lms load humanizer-12b-optiq --identifier humanizer-12b-optiq --context-length 8192 --ttl 900 --yes` if missing.
3. Formats the legacy completion prompt (`instr + "\n\n" + draft + "\n\n### Rewritten:\n\n"`) with `stop: ["### Rewritten"]` and calls `POST http://127.0.0.1:1234/v1/completions` (never `/v1/chat/completions`).
4. Prints only the rewritten text to `stdout` (progress logs go to `stderr`).

## Running `humanize`

Prefer passing the draft via a single-quoted heredoc (`<<'EOF'`) so quotes, newlines, and Markdown survive without shell-escaping issues:

```bash
humanize <<'EOF'
Paste the draft text here.
EOF
```

Other supported input modes:

```bash
# Read draft text from a file
humanize --file path/to/draft.md

# Short single-line text
humanize 'Draft sentence to rewrite.'
```

If `~/.local/bin` is not in `PATH`, run the bundled script directly from this skill's `scripts/humanize` path.

## Output Rule

Always show the user both the **BEFORE** text and the **AFTER** text in your response so they can compare the rewrite directly.
