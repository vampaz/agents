#!/usr/bin/env node

/**
 * Converts a canonical OpenCode V2 agent definition into the Antigravity
 * custom subagent Markdown format (~/.gemini/config/agents/<name>.md).
 *
 * Usage: agent_to_antigravity.mjs <agent.md>
 * Writes the converted definition to stdout.
 */

import { readFileSync } from 'node:fs';
import { basename, dirname } from 'node:path';
import { isMainModule, loadPins, parseFrontmatter, serializeFrontmatter } from './lib/frontmatter.mjs';

export const ANTIGRAVITY_MODELS = new Set(['inherit', 'flash_lite', 'flash', 'pro']);

const INSTRUCTIONS_BY_DENIED_ACTION = {
  edit: 'Do not create, edit, or delete files.',
  shell: 'Do not run shell commands.',
  subagent: 'Do not launch other agents.',
};

export function collectAntigravityRestrictions(frontmatter, source, warn = console.error) {
  const instructions = [];
  let commandExecutionPolicy = null;
  const rules = Array.isArray(frontmatter.permissions) ? frontmatter.permissions : [];

  for (const rule of rules) {
    if (!rule || typeof rule !== 'object') {
      continue;
    }

    const effect = String(rule.effect ?? '');
    const action = String(rule.action ?? '');
    const resource = String(rule.resource ?? '');

    if (effect === 'allow' && resource !== '*') {
      warn(`${source}: cannot express the allow rule for '${action}' on '${resource}' in Antigravity`);
      continue;
    }

    if (effect !== 'deny') {
      continue;
    }

    const instruction = INSTRUCTIONS_BY_DENIED_ACTION[action];
    if (resource !== '*' || !instruction) {
      warn(`${source}: cannot express the deny rule for '${action}' on '${resource}' in Antigravity`);
      continue;
    }

    if (action === 'shell') {
      commandExecutionPolicy = 'off';
    }
    instructions.push(instruction);
  }

  return {
    instructions: [...new Set(instructions)],
    commandExecutionPolicy,
  };
}

export function convertToAntigravity(source, contents, pins, warn = console.error) {
  const { frontmatter, body } = parseFrontmatter(contents, source);
  const name = basename(source, '.md');
  const description = String(frontmatter.description ?? '');

  if (description.trim() === '') {
    throw new Error(`${source}: the description field is required`);
  }

  const mode = String(frontmatter.mode ?? 'subagent');
  const converted = {
    name,
    description,
    subagent: mode !== 'primary',
    mainAgent: mode === 'primary' || mode === 'all',
  };

  const rawPin = pins?.[name]?.antigravity;
  if (rawPin !== undefined && rawPin !== null && String(rawPin).trim() !== '') {
    const model = String(rawPin).trim();
    if (!ANTIGRAVITY_MODELS.has(model)) {
      throw new Error(
        `${source}: invalid antigravity model '${model}' (expected one of ${[...ANTIGRAVITY_MODELS].join(', ')})`,
      );
    }
    converted.model = model;
  }

  const { instructions, commandExecutionPolicy } = collectAntigravityRestrictions(
    frontmatter,
    source,
    warn,
  );
  if (commandExecutionPolicy) {
    converted.commandExecutionPolicy = commandExecutionPolicy;
  }

  const fullBody = [body.trim(), ...instructions].filter(Boolean).join('\n\n');
  return `${serializeFrontmatter(converted)}\n${fullBody}\n`;
}

function main() {
  const source = process.argv[2];
  if (!source) {
    console.error('Usage: agent_to_antigravity.mjs <agent.md>');
    process.exit(1);
  }

  try {
    const contents = readFileSync(source, 'utf8');
    const pins = loadPins(dirname(source));
    process.stdout.write(convertToAntigravity(source, contents, pins));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}

if (isMainModule(import.meta.url)) {
  main();
}
