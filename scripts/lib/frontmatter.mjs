import { existsSync, readFileSync, realpathSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

/**
 * Parses a YAML scalar token into a string, number, boolean, or null.
 */
function parseScalar(raw) {
  const value = raw.trim();
  if (value === '' || value === 'null' || value === '~') {
    return null;
  }

  if (
    (value.startsWith("'") && value.endsWith("'") && value.length >= 2)
  ) {
    return value.slice(1, -1).replaceAll("''", "'");
  }

  if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
    try {
      return JSON.parse(value);
    } catch {
      throw new Error(`invalid double-quoted string: ${value}`);
    }
  }

  if (value === 'true') {
    return true;
  }
  if (value === 'false') {
    return false;
  }
  if (/^-?(?:0|[1-9]\d*)(?:\.\d+)?$/.test(value)) {
    return Number(value);
  }
  if (value === '[]') {
    return [];
  }
  if (value === '{}') {
    return {};
  }

  return value;
}

/**
 * Strips an unquoted inline comment from a YAML line.
 */
function stripInlineComment(line) {
  let inSingle = false;
  let inDouble = false;

  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];

    if (inSingle) {
      if (ch === "'" && line[i + 1] === "'") {
        i += 1;
      } else if (ch === "'") {
        inSingle = false;
      }
      continue;
    }

    if (inDouble) {
      if (ch === '\\') {
        i += 1;
      } else if (ch === '"') {
        inDouble = false;
      }
      continue;
    }

    if (ch === "'") {
      inSingle = true;
    } else if (ch === '"') {
      inDouble = true;
    } else if (ch === '#' && (i === 0 || /\s/.test(line[i - 1]))) {
      return line.slice(0, i).trimEnd();
    }
  }

  return line.trimEnd();
}

/**
 * Splits a YAML key-value line on the first unquoted colon followed by space or EOL.
 */
function splitKeyValue(text) {
  let inSingle = false;
  let inDouble = false;

  for (let i = 0; i < text.length; i += 1) {
    const ch = text[i];

    if (inSingle) {
      if (ch === "'" && text[i + 1] === "'") {
        i += 1;
      } else if (ch === "'") {
        inSingle = false;
      }
      continue;
    }

    if (inDouble) {
      if (ch === '\\') {
        i += 1;
      } else if (ch === '"') {
        inDouble = false;
      }
      continue;
    }

    if (ch === "'") {
      inSingle = true;
    } else if (ch === '"') {
      inDouble = true;
    } else if (ch === ':' && (i + 1 === text.length || /\s/.test(text[i + 1]))) {
      const rawKey = text.slice(0, i).trim();
      const key = parseScalar(rawKey);
      if (typeof key !== 'string' || key.length === 0) {
        throw new Error(`invalid mapping key: ${rawKey}`);
      }
      return { key, rest: text.slice(i + 1).trim() };
    }
  }

  return null;
}

function getIndent(line) {
  let i = 0;
  while (i < line.length && line[i] === ' ') {
    i += 1;
  }
  if (line[i] === '\t') {
    throw new Error('tabs are not supported for YAML indentation');
  }
  return i;
}

function isBlankOrComment(line) {
  const trimmed = line.trim();
  return trimmed === '' || trimmed.startsWith('#');
}

function parseBlockScalar(lines, startIndex, header, parentIndent) {
  const match = header.match(/^([>|])([+-])?$/);
  if (!match) {
    throw new Error(`unsupported block scalar header: ${header}`);
  }

  const style = match[1];
  const chomp = match[2] ?? '';
  const collected = [];
  let blockIndent = null;
  let index = startIndex;

  while (index < lines.length) {
    const line = lines[index];
    if (line.trim() === '') {
      collected.push('');
      index += 1;
      continue;
    }

    const indent = getIndent(line);
    if (indent <= parentIndent) {
      break;
    }

    if (blockIndent === null) {
      blockIndent = indent;
    }

    collected.push(line.slice(Math.min(blockIndent, indent)));
    index += 1;
  }

  let trailingEmpty = 0;
  while (collected.length > 0 && collected[collected.length - 1] === '') {
    collected.pop();
    trailingEmpty += 1;
  }

  let text;
  if (style === '|') {
    text = collected.join('\n');
  } else {
    const parts = [];
    for (let i = 0; i < collected.length; i += 1) {
      const current = collected[i];
      if (current === '') {
        parts.push('\n');
      } else if (i > 0 && collected[i - 1] !== '') {
        parts.push(` ${current}`);
      } else {
        parts.push(current);
      }
    }
    text = parts.join('');
  }

  if (chomp === '+') {
    text += '\n'.repeat(trailingEmpty + (collected.length > 0 ? 1 : 0));
  } else if (chomp === '' && collected.length > 0) {
    text += '\n';
  }

  return { value: text, nextIndex: index };
}

function parseNode(lines, startIndex, minIndent) {
  let index = startIndex;
  while (index < lines.length && isBlankOrComment(lines[index])) {
    index += 1;
  }

  if (index >= lines.length) {
    return { value: null, nextIndex: index };
  }

  const indent = getIndent(lines[index]);
  if (indent < minIndent) {
    return { value: null, nextIndex: index };
  }

  const firstContent = stripInlineComment(lines[index].slice(indent));
  if (firstContent === '-' || firstContent.startsWith('- ')) {
    return parseSequence(lines, index, indent);
  }

  return parseMapping(lines, index, indent);
}

function parseSequence(lines, startIndex, seqIndent) {
  const items = [];
  let index = startIndex;

  while (index < lines.length) {
    if (isBlankOrComment(lines[index])) {
      index += 1;
      continue;
    }

    const indent = getIndent(lines[index]);
    if (indent < seqIndent) {
      break;
    }
    if (indent > seqIndent) {
      throw new Error(`unexpected indentation at line ${index + 1}`);
    }

    const content = stripInlineComment(lines[index].slice(indent));
    if (content !== '-' && !content.startsWith('- ')) {
      break;
    }

    const afterDash = content.slice(1).trim();
    if (afterDash === '') {
      const child = parseNode(lines, index + 1, seqIndent + 1);
      items.push(child.value);
      index = child.nextIndex;
      continue;
    }

    const kv = splitKeyValue(afterDash);
    if (kv) {
      const obj = Object.create(null);
      const itemIndent = indent + content.indexOf(afterDash);

      if (kv.rest === '') {
        const child = parseNode(lines, index + 1, itemIndent + 1);
        obj[kv.key] = child.value;
        index = child.nextIndex;
      } else if (/^[>|][+-]?$/.test(kv.rest)) {
        const block = parseBlockScalar(lines, index + 1, kv.rest, itemIndent);
        obj[kv.key] = block.value;
        index = block.nextIndex;
      } else {
        obj[kv.key] = parseScalar(kv.rest);
        index += 1;
      }

      const restMap = parseMapping(lines, index, itemIndent, obj);
      items.push(restMap.value);
      index = restMap.nextIndex;
      continue;
    }

    if (/^[>|][+-]?$/.test(afterDash)) {
      const block = parseBlockScalar(lines, index + 1, afterDash, seqIndent);
      items.push(block.value);
      index = block.nextIndex;
      continue;
    }

    items.push(parseScalar(afterDash));
    index += 1;
  }

  return { value: items, nextIndex: index };
}

function parseMapping(lines, startIndex, mapIndent, target = Object.create(null)) {
  let index = startIndex;

  while (index < lines.length) {
    if (isBlankOrComment(lines[index])) {
      index += 1;
      continue;
    }

    const indent = getIndent(lines[index]);
    if (indent < mapIndent) {
      break;
    }
    if (indent > mapIndent) {
      throw new Error(`unexpected indentation at line ${index + 1}`);
    }

    const content = stripInlineComment(lines[index].slice(indent));
    if (content === '-' || content.startsWith('- ')) {
      break;
    }

    const kv = splitKeyValue(content);
    if (!kv) {
      throw new Error(`expected key: value at line ${index + 1}`);
    }
    if (Object.hasOwn(target, kv.key)) {
      throw new Error(`duplicate key '${kv.key}' at line ${index + 1}`);
    }

    if (kv.rest === '') {
      const child = parseNode(lines, index + 1, mapIndent + 1);
      target[kv.key] = child.value;
      index = child.nextIndex;
    } else if (/^[>|][+-]?$/.test(kv.rest)) {
      const block = parseBlockScalar(lines, index + 1, kv.rest, mapIndent);
      target[kv.key] = block.value;
      index = block.nextIndex;
    } else {
      target[kv.key] = parseScalar(kv.rest);
      index += 1;
    }
  }

  return { value: target, nextIndex: index };
}

/**
 * Parses a YAML subset sufficient for agent/skill frontmatter and models.yml.
 */
export function parseYaml(yamlText, source = '<input>') {
  const normalized = yamlText.replace(/^\uFEFF/, '').replace(/\r\n/g, '\n');
  const lines = normalized.split('\n');

  try {
    const { value, nextIndex } = parseNode(lines, 0, 0);
    for (let i = nextIndex; i < lines.length; i += 1) {
      if (!isBlankOrComment(lines[i])) {
        throw new Error(`unexpected content at line ${i + 1}`);
      }
    }
    return value ?? Object.create(null);
  } catch (error) {
    throw new Error(`${source}: cannot parse YAML: ${error.message}`);
  }
}

/**
 * Extracts YAML frontmatter and Markdown body from a file's contents.
 */
export function parseFrontmatter(contents, source = '<input>') {
  const normalized = contents.replace(/^\uFEFF/, '').replace(/\r\n/g, '\n');
  const match = normalized.match(/^---[ \t]*\n([\s\S]*?)\n---[ \t]*(?:\n([\s\S]*)|$)/);

  if (!match) {
    throw new Error(`${source}: missing YAML frontmatter`);
  }

  const frontmatter = parseYaml(match[1], source);
  if (frontmatter === null || typeof frontmatter !== 'object' || Array.isArray(frontmatter)) {
    throw new Error(`${source}: frontmatter must be a YAML mapping`);
  }

  return {
    frontmatter,
    body: match[2] ?? '',
  };
}

/**
 * Loads agents/models.yml from the given directory if present.
 */
export function loadPins(dir) {
  const pinsFile = join(dir, 'models.yml');
  if (!existsSync(pinsFile)) {
    return Object.create(null);
  }

  const parsed = parseYaml(readFileSync(pinsFile, 'utf8'), pinsFile);
  if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error(`${pinsFile}: expected a YAML mapping`);
  }
  return parsed;
}

/**
 * Formats a scalar value for single-line YAML emission.
 */
function formatYamlScalar(value) {
  if (typeof value === 'boolean' || typeof value === 'number') {
    return String(value);
  }

  const str = String(value);
  const needsQuotes =
    str === '' ||
    str !== str.trim() ||
    /[\n\r\t:#\[\]{},&*!|>'"%@`?]/.test(str) ||
    /^(?:true|false|null|~|-?(?:0|[1-9]\d*)(?:\.\d+)?)$/i.test(str);

  return needsQuotes ? JSON.stringify(str) : str;
}

/**
 * Serializes a flat object into a YAML frontmatter block delimited by "---".
 */
export function serializeFrontmatter(fields) {
  const lines = ['---'];

  for (const [key, value] of Object.entries(fields)) {
    if (value === undefined || value === null) {
      continue;
    }
    lines.push(`${key}: ${formatYamlScalar(value)}`);
  }

  lines.push('---');
  return `${lines.join('\n')}\n`;
}

/**
 * Converts a string into a TOML basic string using JSON escaping.
 */
export function tomlString(value) {
  return JSON.stringify(String(value));
}

/**
 * Checks whether the given module URL is the active CLI entrypoint.
 */
export function isMainModule(metaUrl) {
  if (!process.argv[1]) {
    return false;
  }
  try {
    return realpathSync(fileURLToPath(metaUrl)) === realpathSync(process.argv[1]);
  } catch {
    return fileURLToPath(metaUrl) === process.argv[1];
  }
}
