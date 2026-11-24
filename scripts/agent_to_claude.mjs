#!/usr/bin/env node

/**
 * Converts a canonical OpenCode V2 agent definition into the Claude Code
 * subagent format.
 *
 * Usage: agent_to_claude.mjs <agent.md>
 * Writes the converted definition to stdout.
 */

import { readFileSync } from 'node:fs';
import { basename, dirname } from 'node:path';
import { isMainModule, loadPins, parseFrontmatter, serializeFrontmatter } from './lib/frontmatter.mjs';

const TOOLS_BY_ACTION = {
  edit: ['Edit', 'Write', 'NotebookEdit'],
  shell: ['Bash', 'PowerShell'],
  subagent: ['Agent'],
  webfetch: ['WebFetch'],
  websearch: ['WebSearch'],
  read: ['Read'],
  glob: ['Glob'],
  grep: ['Grep'],
  skill: ['Skill'],
};

export function claudeModelAlias(model) {
  if (model === null || model === undefined || String(model).trim() === '') {
    return null;
  }

  const text = String(model);
  if (/opus/i.test(text)) {
    return 'opus';
  }
  if (/sonnet/i.test(text)) {
    return 'sonnet';
  }
  if (/haiku/i.test(text)) {
    return 'haiku';
  }
  return null;
}

export function isValidClaudeName(name) {
  if (name.length === 0 || name.startsWith('-') || name.includes(':')) {
    return false;
  }
  return name.length <= 256;
}

export function collectDeniedTools(frontmatter, source, warn = console.error) {
  const denied = [];
  const rules = Array.isArray(frontmatter.permissions) ? frontmatter.permissions : [];

  for (const rule of rules) {
    if (!rule || typeof rule !== 'object') {
      continue;
    }

    const action = String(rule.action ?? '');
    const resource = String(rule.resource ?? '');
    const effect = String(rule.effect ?? '');

    if (effect === 'allow' && resource !== '*') {
      warn(`${source}: cannot express the allow rule for '${action}' on '${resource}' in Claude Code`);
      continue;
    }

    if (effect === 'ask') {
      warn(`${source}: cannot express the ask rule for '${action}' on '${resource}' in Claude Code`);
      continue;
    }

    if (effect !== 'deny') {
      continue;
    }

    if (resource !== '*') {
      warn(`${source}: cannot express the deny rule for '${action}' on '${resource}' in Claude Code`);
      continue;
    }

    if (action === '*') {
      warn(`${source}: cannot express a deny-all rule in Claude Code`);
      continue;
    }

    const mapped = TOOLS_BY_ACTION[action];
    if (!mapped) {
      warn(`${source}: unknown permission action '${action}' for Claude Code`);
      continue;
    }

    denied.push(...mapped);
  }

  return [...new Set(denied)];
}

export function convertToClaude(source, contents, pins, warn = console.error) {
  const { frontmatter, body } = parseFrontmatter(contents, source);
  const description = String(frontmatter.description ?? '');

  if (description.trim() === '') {
    throw new Error(`${source}: the description field is required`);
  }

  const name = basename(source, '.md');
  if (!isValidClaudeName(name)) {
    throw new Error(`${source}: '${name}' is not a valid Claude Code agent name`);
  }

  const converted = {
    name,
    description,
  };

  const tools = collectDeniedTools(frontmatter, source, warn);
  if (tools.length > 0) {
    converted.disallowedTools = tools.join(', ');
  }

  const pin = pins?.[name]?.claude;
  const pinnedModel = typeof pin === 'string' && pin.trim() !== '' ? pin.trim() : null;
  const model = pinnedModel ?? claudeModelAlias(frontmatter.model);
  if (model) {
    converted.model = model;
  }

  return `${serializeFrontmatter(converted)}\n${body.trim()}\n`;
}

function main() {
  const source = process.argv[2];
  if (!source) {
    console.error('Usage: agent_to_claude.mjs <agent.md>');
    process.exit(1);
  }

  try {
    const contents = readFileSync(source, 'utf8');
    const pins = loadPins(dirname(source));
    process.stdout.write(convertToClaude(source, contents, pins));
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}

if (isMainModule(import.meta.url)) {
  main();
}
