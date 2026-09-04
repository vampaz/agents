# PRD: Open-Source Agent Skills Validator for npm

Status: implementation handoff; no library has been built or published.
Prepared: 2026-09-04.
Working CLI name: `skill-validate`; npm name, scope, and repository owner are not reserved.

## Outcome

Build a small, independently maintained npm library and CLI that validates local `SKILL.md` files
without Python. A JavaScript project should be able to use the same validation rules in an editor,
authoring script, or CI command, with clear diagnostics and reliable failure exits.

Keep this in its own repository. Do not implement it inside Annex Reader or `~/agents`. Annex can
later consume it as development tooling; that integration is not part of this PRD.

## Problem and users

Skill authors need more than a YAML syntax check, but should not need a skill installer, agent runtime,
or packaging framework. Our exploratory package checks exposed false rejection of quoted `---` and
Windows line endings, acceptance of malformed YAML and wrong field types, and incompatible default
schemas. These are regression scenarios, not evidence that every competing tool is defective.

Primary users are skill authors checking one directory, maintainers gating changes in CI, and tool
authors validating in-memory content. Success means all three use one predictable rule engine.

This is a structural validator. It must never claim that a passing skill is safe to execute, free of
prompt injection, effective, or accepted by every agent product.

## Scope

V1 includes a pure ESM validation API, a separate Node filesystem adapter, a CLI with text/JSON output,
TypeScript declarations, documented rules, regression tests, and secure release preparation.

V1 excludes skill installation, automatic fixes, network/link checking, recursive discovery, glob
expansion inside the CLI, repositories/archives/URLs as inputs, agent-specific profiles, AI quality
scoring, telemetry, a web UI, plugin systems, and validation of `AGENTS.md` or `agents/openai.yaml`.
Do not add a configuration framework or a schema-validation dependency for six known fields.

## Compatibility baseline

Use the [Agent Skills specification snapshot][spec] at commit
`69ef37e9424c0a7ea9dd2293b559e43ec8176379` as the initial baseline. Record this revision in the package's
documentation and test fixtures. Recheck the live specification before implementation; summarize any
changes rather than silently switching the accepted format.

The [reference validator][reference] informs compatibility but is not an infallible oracle. Do not
copy its source or fixtures without satisfying their license, or preserve demonstrated parser bugs.
The following are explicit V1 interpretations where implementations differ:

- Parse YAML 1.2 core types without silently converting numbers, booleans, or null into strings.
- Accept Unicode letters and numbers in names, including uncased scripts. Normalize names and the
  comparison directory name with NFKC; reject a normalized name that changes under lowercasing.
  Reject whitespace rather than silently trimming names. This is not a promise of identical Unicode
  behavior in every host; document and test these choices.
- Count string limits in Unicode code points, not UTF-16 code units. For descriptions and
  compatibility, count the entire decoded value, including whitespace; reject whitespace-only values.
- Reject unknown top-level fields in this portable profile. Explain that a host extension may be valid
  for that host but unsupported here; do not imply it is universally invalid.
- Enforce the specification's non-empty compatibility rule even if another validator accepts empty
  values. Resource limits below are product safety limits, not limits claimed by the standard.

## Functional requirements

### F1. Input and frontmatter

- Accept LF and CRLF and one optional leading UTF-8 BOM. File input must be valid UTF-8.
- Frontmatter starts at the beginning after the optional BOM. Opening and closing delimiters are
  standalone, unindented `---` lines; allow trailing spaces/tabs and an EOF immediately after the
  closing delimiter. Delimiters do not contain comments or other characters.
- Only a delimiter line closes frontmatter. A quoted or indented `---` inside a YAML value does not.
  Markdown horizontal rules after the closing delimiter are body content, not another YAML document.
- Use a maintained YAML parser, not regular expressions to parse fields. Require one root mapping
  with string keys. Reject malformed YAML, duplicate keys at any depth, unsupported/custom tags,
  invalid aliases, and non-mapping roots without crashing or printing parser source excerpts.
- Support valid quoted, folded, literal, and flow-style values and bounded, non-cyclic aliases. Keep
  the source unchanged; validation never rewrites the document.
- Empty Markdown is accepted. Do not impose headings, trigger phrases, paragraph styles, token counts,
  or a 500-line failure gate; those are authoring concerns, not V1 structural errors.

### F2. Fields

| Field           | Required | V1 validation                                                                                                                                                                                      |
| --------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`          | Yes      | String; normalized length 1–64; Unicode letters/numbers separated by single hyphens; no leading/trailing hyphen; lowercase where casing exists; match the normalized directory name when supplied. |
| `description`   | Yes      | Non-whitespace string, at most 1024 code points after YAML decoding.                                                                                                                               |
| `compatibility` | No       | Non-whitespace string, at most 500 code points after YAML decoding.                                                                                                                                |
| `license`       | No       | String. Do not resolve a file, URL, or SPDX expression.                                                                                                                                            |
| `allowed-tools` | No       | String. Do not parse, execute, authorize, or verify the named tools.                                                                                                                               |
| `metadata`      | No       | Mapping with string keys and string values; reject null, arrays, nested values, and implicit numeric/boolean values. Empty mapping is allowed.                                                     |

Require both mandatory fields even when a host allows them to be omitted. No implicit defaults,
coercion, or host-detection behavior. A missing optional field is different from a field set to null.
Angle brackets and other ordinary characters in a valid description are not XML and are not errors.

### F3. Library and diagnostics

Provide these public entrypoints, with names finalized before the first release:

```ts
// Package root: pure validation, no filesystem, process, or network work.
export declare function validateSkill(
  content: string,
  options?: { directoryName?: string },
): ValidationReport;

// Package /node subpath: filesystem adapter, also used by the CLI.
export declare function validateSkillPath(path: string): Promise<ValidationReport>;
```

`ValidationReport` contains `status` (`valid`, `invalid`, or `error`) and a `diagnostics` array.
Each diagnostic has a stable `code`, an English `message`, and optional `field`, `line`, and `column`.
Positions are 1-based locations in the original document; document the column-count convention.
Do not fabricate a position when it is unavailable. V1 diagnostics are all errors, not quality scores.

- `valid` means no diagnostics. `invalid` means validation or input-resource-limit failures. `error`
  means the operation could not complete, for example an unreadable file or internal failure.
- Ordinary bad content returns a report rather than throwing. Invalid API argument types may throw
  `TypeError`. Do not disguise unexpected implementation errors as an invalid skill.
- The pure API omits only the directory comparison when `directoryName` is absent; no filesystem
  inference. The path adapter always performs it.
- Collect independent field failures after successful parsing. Stop semantic checks when parsing
  fails. Sort diagnostics deterministically by source position then code and field; unlocated entries
  sort last. Limit each target report to 100 diagnostics, with the last slot signaling omitted
  diagnostics only when there are more than 100.
- Define and document codes for frontmatter boundaries, YAML syntax/duplicates, missing/type/length/
  name/directory/unknown-field errors, resource limits, file access, and internal failures. Do not expose
  third-party parser messages/codes as the package's stable public contract.

### F4. Files and CLI

The CLI accepts one or more explicit skill directories or files named exactly `SKILL.md`:

```sh
skill-validate ./my-skill
skill-validate ./one/SKILL.md ./two/SKILL.md --format json
skill-validate -- ./path-starting-with-a-dash/SKILL.md
```

- Support `--help`, `--version`, `--format text|json`, and `--`. Unknown flags, unsupported formats,
  missing arguments, and an empty target list are usage errors. Never report zero targets as success.
- Resolve an explicitly supplied directory symlink to its canonical directory. Use that canonical
  directory's leaf name for comparison. Reject a symlinked `SKILL.md`, non-regular files, and files
  with another basename. Do not traverse sibling directories or read referenced resources.
- Missing `SKILL.md` in an existing directory is a validation failure. A missing input path,
  permission error, directory cycle, or other I/O failure is an operational error. Invalid UTF-8 is a
  validation failure, not a silent replacement-character decode. An unsupported filename or case
  mismatch is invalid; a non-regular file or symlinked `SKILL.md` is an operational error. Detect actual
  filename casing even on case-insensitive filesystems; explain the uppercase-only policy.
- Validate all resolvable targets even if one fails. Deduplicate equivalent canonical inputs and
  preserve first-input order. Never modify inputs or write cache/config files.
- Exit `0` when all targets pass, `1` when at least one is invalid, and `2` for usage/I/O/internal
  failures. Exit `2` takes precedence over `1` in mixed runs; help/version exit `0`.
- JSON output is one object: `{ schemaVersion: 1, status, results, diagnostics }`. `results` contains
  `{ path, status, diagnostics }` per target; top-level diagnostics hold usage/global failures.
  Overall status follows the exit-code precedence. JSON mode writes only that object to stdout and
  no banners, colors, stack traces, or progress messages. Recognized JSON mode also covers failures.
  Help/version are separate informational modes, not validation reports.
- Text output identifies each target, code, field/location when available, and a short explanation.
  Escape terminal control characters in paths, field names, and messages. Do not echo raw YAML values,
  body text, environment variables, or credentials. JSON escaping must preserve machine readability.

### F5. Resource and security boundaries

Assume input is untrusted, including repository pull requests. Validation is offline and inert:
never execute skill scripts, shell commands, templates, tags, frontmatter hooks, or body instructions.
Do not follow embedded URLs, read user agent configuration, inspect credentials, or import code named
by the document. Use safe map handling; keys such as `__proto__` must not mutate object prototypes.

Initial fixed limits: 1 MiB per document (UTF-8 bytes), 64 KiB frontmatter, 64 levels of collection
nesting, and the chosen parser's documented alias-expansion limit of 100. Reject cyclic alias graphs.
Check bytes before unbounded reads/conversion; enforce nesting/alias limits before materializing
expanded structures. Test exact boundaries and clear resource-limit diagnostics. Document how each
limit is measured; do not conflate the parser's alias-expansion metric with a count of `*` characters.
See the [YAML parser options](https://eemeli.org/yaml/#tojs-options) for the candidate parser's alias
metric. Do not disable limits for a test to pass. No configurable limits are required in V1.

## Implementation and dependency constraints

- Node/ESM only, with emitted JavaScript and TypeScript declarations. Consumers need neither Python
  nor a TypeScript runtime/transpiler. Choose a currently supported Node LTS baseline, state the exact
  minimum in `engines`, and test every advertised platform/runtime. Aim for Linux, macOS, and Windows.
- Use the companion `select-dependencies` skill before adding packages. If it is unavailable to the
  implementing agent, inspect exact published versions, licenses, dependency trees, install hooks,
  advisories, integrity/provenance, and the shared regression cases; record the evidence and gaps.
- `yaml` is a candidate, not preapproved forever. Re-evaluate its current stable release. Prefer a
  maintained YAML parser plus Node built-ins, including the Node test runner where practical. Keep
  runtime dependencies to the parser unless a concrete requirement justifies more.
- Separate pure validation from I/O and presentation without a framework or plugin layer. Do not
  promise a browser bundle in V1; the root API must still have no import-time side effects.
- No package install hooks, binary downloads, telemetry, native addons, or consumer-side compilation.
  Audit optional/transitive dependencies too. Use a committed development lockfile and intentional
  consumer dependency ranges; the library's lockfile does not pin downstream installations.

## Acceptance and regression tests

All rows are required evidence, not optional coverage targets. Use shared fixtures for the library,
path adapter, and CLI where applicable. Test actual packed exports and the executable as a consumer.

| Scenario                                                                                                | Required result                                                                                        |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Minimal and full valid skills; LF/CRLF; BOM; delimiter at EOF                                           | Accepted consistently; same field values and diagnoses across line endings.                            |
| `description: "Explain --- separators"`; indented `---`; body horizontal rules                          | No premature frontmatter closure or extra-document error.                                              |
| Missing/open-only/bogus delimiter; malformed YAML; duplicate top-level and nested keys                  | Invalid with stable actionable codes, no crash or leaked source excerpt.                               |
| Folded/literal descriptions and quoted scalars                                                          | Validate decoded values, including exact 1024/1025 boundaries.                                         |
| Missing, empty, whitespace-only, null, numeric, boolean, array, and object required values              | Only valid strings pass; no coercion or implicit defaults.                                             |
| Names at 64/65 code points; uppercase; underscores; edge/double hyphens; directory mismatch             | Enforce the documented name contract.                                                                  |
| Accented/decomposed Unicode names, uncased scripts, and astral characters in descriptions               | NFKC directory comparison and code-point limits behave as documented.                                  |
| Compatibility at 500/501; empty/null optional values; unknown host fields                               | Match F2 and the explicit portable-profile policy.                                                     |
| Valid metadata strings versus non-string keys/values, nested objects, arrays, null                      | Reject incorrect types and duplicate keys without prototype mutation.                                  |
| Custom tags, benign aliases, cyclic/expanding aliases, deep nesting, oversized files                    | Accept bounded valid data; reject unsafe/over-limit input deterministically.                           |
| Exact byte/depth/diagnostic limits and one step over                                                    | No accidental off-by-one acceptance, hangs, uncontrolled expansion, or truncation without notice.      |
| Missing/unreadable paths; invalid UTF-8; lowercase filename; directory/file symlinks; FIFO/device input | Follow F4 without blocking on special files, silently repairing bytes, or reading unrelated resources. |
| Multiple targets, duplicate paths, mixed validation/I/O failures, flags, `--`                           | Deterministic complete report and exact `0`/`1`/`2` precedence.                                        |
| JSON success and failures; hostile terminal escapes in paths/keys                                       | Parseable JSON only on stdout; safe readable text output.                                              |
| Library import and validation with network/subprocess/write access blocked                              | No such side effects; input fixture hashes remain unchanged.                                           |
| Packed package in a clean consumer with scripts disabled                                                | Public imports, types, CLI, and documented minimum Node version work without repository source files.  |

Use independently expected outcomes, not snapshots generated from the implementation under test.
Create a requirements-to-tests matrix. Differential checks against a reference tool can reveal
differences but do not override this contract. Keep Python out of required local and CI tests.
Record performance/resource measurements for the adversarial fixtures; avoid flaky wall-clock unit
assertions. Isolate hostile-input tests with bounded process time and memory so a regression cannot
hang the whole suite.

## Packaging and release security

Prepare README usage/API/rules, a proposed MIT license, SECURITY.md with a maintainer-approved reporting
channel, a minimal CONTRIBUTING.md, changelog, and explicit package `files`, `exports`, `types`, `bin`,
`engines`, and repository metadata. Do not imply affiliation with the Agent Skills specification owners.
Reconfirm package-name availability, ownership, license choice, and support contact before publishing.

CI must test the source and the exact publishable tarball. Audit production and development trees,
review unresolved findings, and verify available signatures/provenance; a clean audit is not a safety
guarantee. Inspect tarball contents for unintended files and secrets. Pin GitHub Actions to full commit
SHAs and grant only needed permissions; untrusted PR jobs must never receive publishing authority.

Prepare a maintainer-approved release flow using [npm trusted publishing][publishing] with a public
source repository and verified provenance. Keep publish permission scoped to the release job and
avoid long-lived npm write tokens. Test the same tarball that will be released; verify registry
integrity, provenance, source revision, and a fresh consumer smoke test after an authorized release.
Initial registry setup/bootstrap may require owner action; document it rather than bypassing approval.

Public repository creation, account settings, releases, and npm publication require the owner's
explicit authorization. Preparing code and workflows is not permission to publish them.

## Delivery milestones and definition of done

1. Freeze the compatibility choices, supported runtime, package identity proposal, and dependency
   decision. Deliver the requirement/fixture matrix before implementation.
2. Implement the parser boundary and field rules with adversarial tests, then the filesystem adapter
   and CLI. Verify no behavioral drift between entrypoints.
3. Pass the complete acceptance suite on the advertised matrix, type and formatting/lint checks,
   dependency review, side-effect checks, and clean packed-consumer tests. Review and repair the final
   revision before marking implementation complete.
4. Hand off source, tests, documentation, measured evidence, remaining risks, and owner-only release
   steps. Distinguish locally implemented, CI verified, and publicly released states. Do not wait for
   publishing approval to deliver a tested implementation.

The implementation agent should keep a checklist of these milestones and report blockers against
specific requirements. No speculative features are needed to declare V1 complete.

## Prompt for the implementation agent

> Implement the V1 library and CLI defined in this PRD in a separate repository/workspace I provide.
> Read its local guidance first. Use `select-dependencies` if available, or the dependency checks in
> this document. Turn the acceptance matrix into tests and implement only the stated scope. Keep
> Python out of both the package and its required toolchain. Review, repair, and verify the exact
> deliverable, including a packed-consumer test. Report completed checks, limitations, and release
> prerequisites. Do not change Annex Reader or `~/agents`, create a public repository, publish to npm,
> or change account settings without my explicit authorization.

[spec]: https://github.com/agentskills/agentskills/blob/69ef37e9424c0a7ea9dd2293b559e43ec8176379/docs/specification.mdx
[reference]: https://github.com/agentskills/agentskills/blob/69ef37e9424c0a7ea9dd2293b559e43ec8176379/skills-ref/src/skills_ref/validator.py
[publishing]: https://docs.npmjs.com/trusted-publishers/
