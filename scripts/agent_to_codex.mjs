#!/usr/bin/env node

/**
 * Converts a canonical OpenCode V2 agent definition into a Codex TOML custom
 * agent file.
 *
 * Usage:
 *   agent_to_codex.mjs --list <agents dir>   Lists the agents pinned for Codex.
 *   agent_to_codex.mjs <agent.md>            Writes the TOML agent to stdout.
 */

import { readFileSync } from 'node:fs';
import { basename, dirname } from 'node:path';
import { isMainModule, loadPins, parseFrontmatter, tomlString } from './lib/frontmatter.mjs';

const INSTRUCTIONS_BY_DENIED_ACTION = {
  edit: 'Do not create, edit, or delete files.',
  shell: 'Do not run shell commands.',
  subagent: 'Do not launch other agents.',
};

export function listCodexAgents(pins) {
  const names = [];

  for (const [name, pin] of Object.entries(pins ?? {})) {
    if (pin && typeof pin === 'object' && typeof pin.codex === 'string' && pin.codex.trim() !== '') {
      names.push(name);
    }
  }

  return names;
}

export function collectCodexDeniedInstructions(frontmatter, source, warn = console.error) {
  const instructions = [];
  const rules = Array.isArray(frontmatter.permissions) ? frontmatter.permissions : [];

  for (const rule of rules) {
    if (!rule || typeof rule !== 'object') {
      continue;
    }

    const effect = String(rule.effect ?? '');
    const action = String(rule.action ?? '');
    const resource = String(rule.resource ?? '');

    if (effect === 'allow' && resource !== '*') {
      warn(`${source}: cannot express the allow rule for '${action}' on '${resource}' in Codex`);
      continue;
    }

    if (effect !== 'deny') {
      continue;
    }

    const instruction = INSTRUCTIONS_BY_DENIED_ACTION[action];
    if (resource !== '*' || !instruction) {
      warn(`${source}: cannot express the deny rule for '${action}' on '${resource}' in Codex`);
      continue;
    }

    instructions.push(instruction);
  }

  return [...new Set(instructions)];
}

export function parseCodexPin(rawPin, source) {
  const pin = String(rawPin ?? '').trim();
  if (pin === '') {
    throw new Error(`${source}: no codex model in models.yml`);
  }

  const hashIndex = pin.indexOf('#');
  if (hashIndex === -1) {
    return { model: pin, effort: null };
  }

  const model = pin.slice(0, hashIndex).trim();
  const effort = pin.slice(hashIndex + 1).trim();

  if (model === '') {
    throw new Error(`${source}: the codex pin has an empty model name`);
  }
  if (effort === '') {
    throw new Error(`${source}: the codex pin has an empty reasoning effort`);
  }

  return { model, effort };
}

export function convertToCodex(source, contents, pins, warn = console.error) {
  const { frontmatter, body } = parseFrontmatter(contents, source);
  const name = basename(source, '.md');
  const description = String(frontmatter.description ?? '');

  if (description.trim() === '') {
    throw new Error(`${source}: the description field is required`);
  }

  const { model, effort } = parseCodexPin(pins?.[name]?.codex, source);
  const denied = collectCodexDeniedInstructions(frontmatter, source, warn);
  const instructions = [body.trim(), ...denied].filter(Boolean).join('\n\n');

  const lines = [
    `name = ${tomlString(name)}`,
    `description = ${tomlString(description)}`,
    `model = ${tomlString(model)}`,
  ];

  if (effort) {
    lines.push(`model_reasoning_effort = ${tomlString(effort)}`);
  }

  lines.push(`developer_instructions = ${tomlString(instructions)}`);
  return `${lines.join('\n')}\n`;
}

function main() {
  try {
    if (process.argv[2] === '--list') {
      const dir = process.argv[3];
      if (!dir) {
        console.error('Usage: agent_to_codex.mjs --list <agents dir>');
        process.exit(1);
      }

      const names = listCodexAgents(loadPins(dir));
      if (names.length > 0) {
        process.stdout.write(`${names.join('\n')}\n`);
      }
      return;
    }

    const source = process.argv[2];
    if (!source) {
      console.error('Usage: agent_to_codex.mjs <agent.md>');
      process.exit(1);
    }

    const contents = readFileSync(source, 'utf8');
    const pins = loadPins(dirname(source));
    process.stdout.write(convertToCodex(source, contents, pins));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}

if (isMainModule(import.meta.url)) {
  main();
}
