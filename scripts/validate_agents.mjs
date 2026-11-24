#!/usr/bin/env node

/**
 * Validates that every agent definition matches the schema of the target harness.
 *
 * Usage: validate_agents.mjs <dir> <opencode|claude|codex|antigravity>
 *
 * When <dir> holds a .sync_agents_manifest, only the files listed in it are
 * validated. When validating the source directory with schema "opencode" and
 * models.yml is present, models.yml pins are also validated.
 */

import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { ANTIGRAVITY_MODELS } from './agent_to_antigravity.mjs';
import { isValidClaudeName } from './agent_to_claude.mjs';
import { parseCodexPin } from './agent_to_codex.mjs';
import { isMainModule, loadPins, parseFrontmatter } from './lib/frontmatter.mjs';

const VALID_SCHEMAS = new Set(['opencode', 'claude', 'codex', 'antigravity']);
const OPENCODE_KEYS = new Set([
  'description',
  'mode',
  'model',
  'permissions',
  'steps',
  'hidden',
  'color',
  'disabled',
  'request',
]);
const OPENCODE_MODES = new Set(['primary', 'subagent', 'all']);
const CLAUDE_KEYS = new Set(['name', 'description', 'model', 'disallowedTools', 'tools']);
const ANTIGRAVITY_KEYS = new Set([
  'name',
  'description',
  'subagent',
  'mainAgent',
  'model',
  'tools',
  'commandExecutionPolicy',
  'mcpServers',
  'skills',
  'plugins',
]);
const ANTIGRAVITY_EXEC_POLICIES = new Set(['off', 'auto', 'eager', 'sandbox']);
const ALLOWED_PIN_HARNESSES = new Set(['claude', 'codex', 'antigravity']);

function parseSimpleToml(contents, source) {
  const result = Object.create(null);
  const lines = contents.replace(/^\uFEFF/, '').replace(/\r\n/g, '\n').split('\n');

  for (let i = 0; i < lines.length; i += 1) {
    const trimmed = lines[i].trim();
    if (trimmed === '' || trimmed.startsWith('#')) {
      continue;
    }

    const match = trimmed.match(/^([A-Za-z0-9_-]+)\s*=\s*(.+)$/);
    if (!match) {
      throw new Error(`${source}: invalid TOML assignment at line ${i + 1}`);
    }

    const [, key, rawValue] = match;
    if (Object.hasOwn(result, key)) {
      throw new Error(`${source}: duplicate TOML key '${key}' at line ${i + 1}`);
    }

    if (rawValue.startsWith('"')) {
      try {
        result[key] = JSON.parse(rawValue);
      } catch {
        throw new Error(`${source}: invalid TOML string for '${key}' at line ${i + 1}`);
      }
    } else if (rawValue === 'true' || rawValue === 'false') {
      result[key] = rawValue === 'true';
    } else {
      throw new Error(`${source}: unsupported TOML value for '${key}' at line ${i + 1}`);
    }
  }

  return result;
}

export function validateModelsYml(dir) {
  const errors = [];
  const pinsFile = join(dir, 'models.yml');
  if (!existsSync(pinsFile)) {
    return errors;
  }

  let pins;
  try {
    pins = loadPins(dir);
  } catch (error) {
    return [error.message];
  }

  for (const [agentName, pin] of Object.entries(pins)) {
    const agentFile = join(dir, `${agentName}.md`);
    if (!existsSync(agentFile)) {
      errors.push(`models.yml: pin for '${agentName}' has no matching ${agentName}.md`);
    }

    if (!pin || typeof pin !== 'object' || Array.isArray(pin)) {
      errors.push(`models.yml: pin for '${agentName}' must be a mapping`);
      continue;
    }

    for (const [harness, value] of Object.entries(pin)) {
      if (!ALLOWED_PIN_HARNESSES.has(harness)) {
        errors.push(`models.yml: unknown harness '${harness}' under '${agentName}'`);
        continue;
      }

      if (typeof value !== 'string' || value.trim() === '') {
        errors.push(`models.yml: empty '${harness}' pin under '${agentName}'`);
        continue;
      }

      if (harness === 'codex') {
        try {
          parseCodexPin(value, `models.yml (${agentName})`);
        } catch (error) {
          errors.push(error.message);
        }
      } else if (harness === 'antigravity' && !ANTIGRAVITY_MODELS.has(value.trim())) {
        errors.push(
          `models.yml: invalid antigravity model '${value}' under '${agentName}'`,
        );
      }
    }
  }

  return errors;
}

function collectTargetPaths(dir, schema) {
  const manifest = join(dir, '.sync_agents_manifest');
  if (existsSync(manifest)) {
    return readFileSync(manifest, 'utf8')
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
      .sort()
      .map((file) => join(dir, file));
  }

  const ext = schema === 'codex' ? '.toml' : '.md';
  return readdirSync(dir)
    .filter((file) => file.endsWith(ext))
    .sort()
    .map((file) => join(dir, file));
}

export function validateAgentsDirectory(dir, schema) {
  if (!VALID_SCHEMAS.has(schema)) {
    throw new Error(
      `Unknown schema '${schema}' (expected one of: ${[...VALID_SCHEMAS].join(', ')})`,
    );
  }

  const results = [];
  let failures = 0;

  for (const path of collectTargetPaths(dir, schema)) {
    const name = basename(path);
    if (!existsSync(path)) {
      results.push({ ok: false, message: `FAIL ${name}: file listed in manifest does not exist` });
      failures += 1;
      continue;
    }

    const contents = readFileSync(path, 'utf8');

    if (schema === 'codex') {
      let data;
      try {
        data = parseSimpleToml(contents, name);
      } catch (error) {
        results.push({ ok: false, message: `FAIL ${error.message}` });
        failures += 1;
        continue;
      }

      const missing = ['name', 'description', 'model', 'developer_instructions'].filter(
        (key) => typeof data[key] !== 'string' || data[key].trim() === '',
      );

      if (missing.length > 0) {
        results.push({ ok: false, message: `FAIL ${name}: missing required fields ${missing.join(', ')}` });
        failures += 1;
      } else {
        results.push({
          ok: true,
          message: `OK   ${name} name=${data.name} model=${JSON.stringify(data.model)} effort=${JSON.stringify(data.model_reasoning_effort ?? null)}`,
        });
      }
      continue;
    }

    let frontmatter;
    try {
      ({ frontmatter } = parseFrontmatter(contents, name));
    } catch (error) {
      results.push({ ok: false, message: `FAIL ${error.message}` });
      failures += 1;
      continue;
    }

    if (schema === 'opencode') {
      const unknown = Object.keys(frontmatter).filter((key) => !OPENCODE_KEYS.has(key));
      const description = String(frontmatter.description ?? '');
      const mode = frontmatter.mode;

      if (description.trim() === '') {
        results.push({ ok: false, message: `FAIL ${name}: missing description` });
        failures += 1;
      } else if (!OPENCODE_MODES.has(mode)) {
        results.push({
          ok: false,
          message: `FAIL ${name}: mode is ${JSON.stringify(mode)}, expected one of ${[...OPENCODE_MODES].join(', ')}`,
        });
        failures += 1;
      } else if (unknown.length > 0) {
        results.push({ ok: false, message: `FAIL ${name}: unknown keys ${JSON.stringify(unknown)}` });
        failures += 1;
      } else {
        const permCount = Array.isArray(frontmatter.permissions) ? frontmatter.permissions.length : 0;
        results.push({
          ok: true,
          message: `OK   ${name} mode=${mode} model=${JSON.stringify(frontmatter.model ?? null)} permissions=${permCount}`,
        });
      }
    } else if (schema === 'claude') {
      const unknown = Object.keys(frontmatter).filter((key) => !CLAUDE_KEYS.has(key));
      const agentName = String(frontmatter.name ?? '');
      const description = String(frontmatter.description ?? '');

      if (description.trim() === '') {
        results.push({ ok: false, message: `FAIL ${name}: missing description` });
        failures += 1;
      } else if (!isValidClaudeName(agentName)) {
        results.push({ ok: false, message: `FAIL ${name}: invalid agent name ${JSON.stringify(agentName)}` });
        failures += 1;
      } else if (unknown.length > 0) {
        results.push({ ok: false, message: `FAIL ${name}: unknown keys ${JSON.stringify(unknown)}` });
        failures += 1;
      } else {
        results.push({
          ok: true,
          message: `OK   ${name} name=${agentName} model=${JSON.stringify(frontmatter.model ?? null)} disallowed=${JSON.stringify(frontmatter.disallowedTools ?? null)}`,
        });
      }
    } else if (schema === 'antigravity') {
      const unknown = Object.keys(frontmatter).filter((key) => !ANTIGRAVITY_KEYS.has(key));
      const agentName = String(frontmatter.name ?? '');
      const description = String(frontmatter.description ?? '');

      if (agentName.trim() === '') {
        results.push({ ok: false, message: `FAIL ${name}: missing name` });
        failures += 1;
      } else if (description.trim() === '') {
        results.push({ ok: false, message: `FAIL ${name}: missing description` });
        failures += 1;
      } else if (unknown.length > 0) {
        results.push({ ok: false, message: `FAIL ${name}: unknown keys ${JSON.stringify(unknown)}` });
        failures += 1;
      } else if (frontmatter.model !== undefined && !ANTIGRAVITY_MODELS.has(String(frontmatter.model))) {
        results.push({
          ok: false,
          message: `FAIL ${name}: invalid antigravity model ${JSON.stringify(frontmatter.model)}`,
        });
        failures += 1;
      } else if (
        frontmatter.commandExecutionPolicy !== undefined &&
        !ANTIGRAVITY_EXEC_POLICIES.has(String(frontmatter.commandExecutionPolicy))
      ) {
        results.push({
          ok: false,
          message: `FAIL ${name}: invalid commandExecutionPolicy ${JSON.stringify(frontmatter.commandExecutionPolicy)}`,
        });
        failures += 1;
      } else {
        results.push({
          ok: true,
          message: `OK   ${name} name=${agentName} model=${JSON.stringify(frontmatter.model ?? 'inherit')} exec=${JSON.stringify(frontmatter.commandExecutionPolicy ?? 'default')}`,
        });
      }
    }
  }

  if (schema === 'opencode' && existsSync(join(dir, 'models.yml'))) {
    const pinErrors = validateModelsYml(dir);
    if (pinErrors.length === 0) {
      results.push({ ok: true, message: 'OK   models.yml' });
    } else {
      for (const err of pinErrors) {
        results.push({ ok: false, message: `FAIL ${err}` });
        failures += 1;
      }
    }
  }

  return { failures, results };
}

function main() {
  const dir = process.argv[2];
  const schema = process.argv[3];

  if (!dir || !schema) {
    console.error('Usage: validate_agents.mjs <dir> <opencode|claude|codex|antigravity>');
    process.exit(1);
  }

  try {
    const { failures, results } = validateAgentsDirectory(dir, schema);
    for (const item of results) {
      console.log(item.message);
    }
    process.exit(failures === 0 ? 0 : 1);
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}

if (isMainModule(import.meta.url)) {
  main();
}
