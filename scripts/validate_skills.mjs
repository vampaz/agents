#!/usr/bin/env node

/**
 * Validates every SKILL.md under a skills directory against the portable
 * Agent Skills frontmatter contract.
 *
 * Usage: validate_skills.mjs <skills dir>
 */

import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { isMainModule, parseFrontmatter } from './lib/frontmatter.mjs';

const ALLOWED_SKILL_KEYS = new Set([
  'name',
  'description',
  'license',
  'compatibility',
  'allowed-tools',
  'metadata',
]);

const SKILL_NAME_PATTERN = /^[\p{Ll}\p{Lo}\p{Nd}]+(?:-[\p{Ll}\p{Lo}\p{Nd}]+)*$/u;

function codePointLength(value) {
  return [...value].length;
}

export function validateSkillEntry(dirName, contents) {
  const errors = [];
  let frontmatter;

  try {
    ({ frontmatter } = parseFrontmatter(contents, `${dirName}/SKILL.md`));
  } catch (error) {
    return [error.message];
  }

  const unknown = Object.keys(frontmatter).filter((key) => !ALLOWED_SKILL_KEYS.has(key));
  if (unknown.length > 0) {
    errors.push(`unknown frontmatter keys: ${unknown.join(', ')}`);
  }

  const { name, description, compatibility, license, metadata } = frontmatter;
  const allowedTools = frontmatter['allowed-tools'];

  if (typeof name !== 'string' || name.trim() === '') {
    errors.push('missing or non-string name');
  } else {
    const normalizedName = name.normalize('NFKC');
    const normalizedDir = dirName.normalize('NFKC');
    if (codePointLength(normalizedName) > 64) {
      errors.push('name exceeds 64 code points');
    }
    if (!SKILL_NAME_PATTERN.test(normalizedName) || normalizedName !== normalizedName.toLowerCase()) {
      errors.push(`invalid skill name '${name}'`);
    }
    if (normalizedName !== normalizedDir) {
      errors.push(`name '${name}' does not match directory '${dirName}'`);
    }
  }

  if (typeof description !== 'string' || description.trim() === '') {
    errors.push('missing or empty description');
  } else if (codePointLength(description) > 1024) {
    errors.push(`description exceeds 1024 code points (${codePointLength(description)})`);
  }

  if (compatibility !== undefined) {
    if (typeof compatibility !== 'string' || compatibility.trim() === '') {
      errors.push('compatibility must be a non-empty string');
    } else if (codePointLength(compatibility) > 500) {
      errors.push('compatibility exceeds 500 code points');
    }
  }

  if (license !== undefined && typeof license !== 'string') {
    errors.push('license must be a string');
  }

  if (allowedTools !== undefined && typeof allowedTools !== 'string') {
    errors.push('allowed-tools must be a string');
  }

  if (metadata !== undefined) {
    if (metadata === null || typeof metadata !== 'object' || Array.isArray(metadata)) {
      errors.push('metadata must be a string-to-string mapping');
    } else {
      for (const [k, v] of Object.entries(metadata)) {
        if (typeof v !== 'string') {
          errors.push(`metadata.${k} must be a string`);
        }
      }
    }
  }

  return errors;
}

export function validateSkillsDirectory(skillsDir) {
  const entries = readdirSync(skillsDir)
    .filter((entry) => !entry.startsWith('.'))
    .sort()
    .filter((entry) => statSync(join(skillsDir, entry)).isDirectory());

  const results = [];
  let failures = 0;

  for (const dirName of entries) {
    const skillFile = join(skillsDir, dirName, 'SKILL.md');
    if (!existsSync(skillFile)) {
      results.push({ ok: false, message: `FAIL ${dirName}: missing SKILL.md` });
      failures += 1;
      continue;
    }

    const errors = validateSkillEntry(dirName, readFileSync(skillFile, 'utf8'));
    if (errors.length > 0) {
      results.push({ ok: false, message: `FAIL ${dirName}: ${errors.join('; ')}` });
      failures += 1;
    } else {
      results.push({ ok: true, message: `OK   ${dirName}` });
    }
  }

  return { failures, results };
}

function main() {
  const skillsDir = process.argv[2];
  if (!skillsDir) {
    console.error('Usage: validate_skills.mjs <skills dir>');
    process.exit(1);
  }

  const { failures, results } = validateSkillsDirectory(skillsDir);
  for (const item of results) {
    console.log(item.message);
  }
  process.exit(failures === 0 ? 0 : 1);
}

if (isMainModule(import.meta.url)) {
  main();
}
