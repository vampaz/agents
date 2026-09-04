# npm Package Review

Use this when evaluating an npm dependency. Apply checks to an exact version and record the date.
Do not add an audit framework to the project just to choose one package.

## Inspect without running the candidate

Use the configured registry for private packages. For public packages, registry metadata can establish
the exact name, version, tarball URL, integrity, publisher, repository, engines, exports, dependencies,
scripts, and available attestations. For example, after replacing the placeholders:

```sh
npm view <package>@<version> name version repository maintainers license engines exports bin dependencies optionalDependencies peerDependencies scripts dist --json
```

- Confirm the registry name actually exists. An advertised command or repository URL does not prove
  that the package is published, owned by that repository, or an official implementation.
- Compare recent releases and ownership changes. A fresh release is not automatically preferable to
  an established compatible one; respect the project's version policy and explain conflicts.
- Fetch the registry tarball directly for inspection, or use a package-manager download mode that
  disables lifecycle scripts. List archive entries before extracting into a fresh temporary directory;
  reject traversal paths and unsafe links. Never extract over the project.
- Verify downloaded bytes against `dist.integrity`. Inspect the tarball manifest and entrypoints,
  especially `preinstall`, `install`, `postinstall`, and `prepare`. Do not infer hook absence from the
  root package alone: resolved dependencies can have hooks too.
- Trace executable code back to the claimed source revision when possible. Watch for unexpected
  obfuscation, bundled dependencies, credential access, telemetry, binary downloads, remote loaders,
  and filesystem or shell operations unrelated to the package's job.

## Resolve and audit the likely choice

Create a disposable audit workspace with only the candidate pinned to the evaluated version. Resolve
its dependency tree with lifecycle scripts disabled, without altering the application's manifest or
lockfile. Inspect non-registry Git, URL, and local-file dependency sources before allowing resolution;
do not grant them access to private registries or local paths just because a manifest names them.
Inspect runtime, optional/platform-specific, and peer dependencies, not only the direct list.
Do not treat a Linux-only resolution as proof that the macOS/Windows trees are clear.

- Query advisories for exact resolved versions using npm's audit service and/or
  [OSV](https://osv.dev/). Record affected ranges, severity, reachability, fixes, and database failures.
  An unavailable database is an incomplete check, not a clean result.
- Separate runtime findings from development/release-tool findings, but assess both: a build-time
  dependency may run with publishing credentials. Do not use `npm audit fix` as an audit step.
- Verify [npm registry signatures](https://docs.npmjs.com/verifying-registry-signatures/) with supported
  tooling, such as `npm audit signatures` in the isolated installed tree. For provenance, verify the
  attestation and expected source/workflow identity, not merely the presence of a badge or URL.
- A digest matches bytes; a registry signature authenticates registry metadata; provenance links an
  artifact to its build/source identity. None proves the implementation harmless. Report absent,
  unsupported, failed, and successfully verified evidence separately.

Do not inherit publishing tokens, application secrets, SSH agents, or unrelated npm configuration into
candidate execution. Package acquisition and advisory queries need network access; behavioral tests
should not have it unless the required behavior genuinely needs it. Use OS/container isolation for
untrusted execution when available. If adequate isolation is unavailable, keep execution to code you
have inspected and report the remaining limitation; do not call a VM or temporary folder a sandbox.

## Prove the contract

Exercise the published API or CLI, not a rewritten approximation. Install with scripts disabled only
inside the audit workspace, and do not enable an unexpected required hook without inspecting it and
confirming the task's authority. Use existing project tools directly instead of downloading another
copy through `npx`.

Test valid inputs as well as rejection cases. For a parser/validator, include quoted delimiters,
multiline values, duplicate keys, incorrect types, size limits, line endings, and process exit codes.
For other packages, choose equivalent cases from their actual contract. Check that errors are useful
and that tests do not merely assert the implementation's own assumptions.

If adoption is authorized, recheck the application's final lockfile: its resolution may differ from the
audit workspace. Preserve the decision evidence in the task report or an existing dependency-decision
location. Do not turn temporary audit files or credentials into shipped package content.
