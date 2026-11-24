import assert from 'node:assert/strict';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { convertToAntigravity } from './agent_to_antigravity.mjs';
import { convertToClaude } from './agent_to_claude.mjs';
import { convertToCodex, listCodexAgents } from './agent_to_codex.mjs';
import { parseFrontmatter, parseYaml, serializeFrontmatter } from './lib/frontmatter.mjs';
import { validateAgentsDirectory, validateModelsYml } from './validate_agents.mjs';
import { validateSkillEntry } from './validate_skills.mjs';

test('parseYaml handles nested maps, sequences of maps, quoted scalars, and block scalars', () => {
  const yaml = [
    '# comment',
    'description: >-',
    '  Line one',
    '  line two',
    'mode: subagent',
    'steps: 60',
    'enabled: true',
    'permissions:',
    '  - action: edit',
    "    resource: '*'",
    '    effect: deny',
    '  - action: subagent',
    "    resource: '*'",
    '    effect: deny',
  ].join('\n');

  const parsed = parseYaml(yaml);
  assert.equal(parsed.description, 'Line one line two');
  assert.equal(parsed.mode, 'subagent');
  assert.equal(parsed.steps, 60);
  assert.equal(parsed.enabled, true);
  assert.deepEqual(
    parsed.permissions.map((p) => ({ ...p })),
    [
      { action: 'edit', resource: '*', effect: 'deny' },
      { action: 'subagent', resource: '*', effect: 'deny' },
    ],
  );
});

test('parseFrontmatter accepts CRLF and rejects duplicate keys', () => {
  const crlf = '---\r\nname: demo\r\ndescription: Hello\r\n---\r\nBody\r\n';
  const { frontmatter, body } = parseFrontmatter(crlf);
  assert.equal(frontmatter.name, 'demo');
  assert.equal(body, 'Body\n');

  assert.throws(() => parseFrontmatter('---\nname: a\nname: b\n---\n'), /duplicate key/);
});

test('convertToClaude maps permissions, warns on unknown actions, and respects pins', () => {
  const warnings = [];
  const source = [
    '---',
    'description: Watches checks',
    'mode: subagent',
    'model: openai/gpt-6-luna',
    'permissions:',
    '  - action: edit',
    "    resource: '*'",
    '    effect: deny',
    '  - action: mystery',
    "    resource: '*'",
    '    effect: deny',
    '---',
    '',
    'Watch carefully.',
  ].join('\n');

  const out = convertToClaude(
    '/tmp/watcher.md',
    source,
    { watcher: { claude: 'haiku' } },
    (msg) => warnings.push(msg),
  );

  const { frontmatter, body } = parseFrontmatter(out);
  assert.equal(frontmatter.name, 'watcher');
  assert.equal(frontmatter.model, 'haiku');
  assert.equal(frontmatter.disallowedTools, 'Edit, Write, NotebookEdit');
  assert.equal(body.trim(), 'Watch carefully.');
  assert.equal(warnings.length, 1);
  assert.match(warnings[0], /unknown permission action 'mystery'/);
});

test('convertToCodex emits valid TOML and ignores empty codex pins in list', () => {
  assert.deepEqual(
    listCodexAgents({ watcher: { codex: 'gpt-6-luna#medium' }, empty: { codex: '   ' } }),
    ['watcher'],
  );

  const source = [
    '---',
    'description: Watches checks',
    'mode: subagent',
    'permissions:',
    '  - action: edit',
    "    resource: '*'",
    '    effect: deny',
    '---',
    '',
    'Watch carefully.',
  ].join('\n');

  const toml = convertToCodex(
    '/tmp/watcher.md',
    source,
    { watcher: { codex: 'gpt-6-luna#medium' } },
    () => {},
  );

  assert.match(toml, /name = "watcher"/);
  assert.match(toml, /model = "gpt-6-luna"/);
  assert.match(toml, /model_reasoning_effort = "medium"/);
  assert.match(toml, /Do not create, edit, or delete files\./);
});

test('convertToAntigravity maps model pins, shell deny policy, and denied instructions', () => {
  const source = [
    '---',
    'description: Reviews code',
    'mode: subagent',
    'permissions:',
    '  - action: edit',
    "    resource: '*'",
    '    effect: deny',
    '  - action: shell',
    "    resource: '*'",
    '    effect: deny',
    '---',
    '',
    'Review carefully.',
  ].join('\n');

  const out = convertToAntigravity(
    '/tmp/review.md',
    source,
    { review: { antigravity: 'flash' } },
    () => {},
  );

  const { frontmatter, body } = parseFrontmatter(out);
  assert.equal(frontmatter.name, 'review');
  assert.equal(frontmatter.subagent, true);
  assert.equal(frontmatter.mainAgent, false);
  assert.equal(frontmatter.model, 'flash');
  assert.equal(frontmatter.commandExecutionPolicy, 'off');
  assert.match(body, /Do not create, edit, or delete files\./);
  assert.match(body, /Do not run shell commands\./);
});

test('validateAgentsDirectory rejects unknown schema and validates models.yml', () => {
  const dir = mkdtempSync(join(tmpdir(), 'agents-test-'));
  try {
    writeFileSync(
      join(dir, 'watcher.md'),
      '---\ndescription: Watch\nmode: subagent\n---\nBody\n',
    );
    writeFileSync(
      join(dir, 'models.yml'),
      'watcher:\n  claude: haiku\n  codex: gpt-6-luna#medium\n  antigravity: flash\nghost:\n  claude: haiku\n',
    );

    assert.throws(() => validateAgentsDirectory(dir, 'bogus'), /Unknown schema/);
    const pinErrors = validateModelsYml(dir);
    assert.equal(pinErrors.length, 1);
    assert.match(pinErrors[0], /ghost/);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});

test('validateSkillEntry catches unknown fields and directory mismatches', () => {
  assert.deepEqual(
    validateSkillEntry('my-skill', '---\nname: my-skill\ndescription: Does work\n---\n'),
    [],
  );

  const errs = validateSkillEntry(
    'my-skill',
    '---\nname: other-skill\ndescription: Does work\nreferences:\n  - a\n---\n',
  );
  assert.equal(errs.length, 2);
  assert.match(errs.join(' '), /unknown frontmatter keys: references/);
  assert.match(errs.join(' '), /does not match directory/);
});

test('serializeFrontmatter quotes values with colons cleanly', () => {
  const out = serializeFrontmatter({ name: 'demo', description: 'Key: value' });
  const { frontmatter } = parseFrontmatter(`${out}\nBody\n`);
  assert.equal(frontmatter.name, 'demo');
  assert.equal(frontmatter.description, 'Key: value');
});

test('parseYaml handles sequence mapping items with extra spaces after dash', () => {
  const yaml = [
    'permissions:',
    '  -   action: edit',
    "      resource: '*'",
    '      effect: deny',
  ].join('\n');
  const parsed = parseYaml(yaml);
  assert.deepEqual(
    parsed.permissions.map((p) => ({ ...p })),
    [{ action: 'edit', resource: '*', effect: 'deny' }],
  );
});
