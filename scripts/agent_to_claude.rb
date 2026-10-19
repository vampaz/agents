#!/usr/bin/env ruby
# frozen_string_literal: true

# Converts a canonical agent definition into the Claude Code subagent format.
#
# The canonical definitions in agents/ use the OpenCode V2 schema:
#
#   ---
#   description: ...
#   mode: subagent
#   model: provider/model
#   permissions:
#     - action: edit
#       resource: '*'
#       effect: deny
#   ---
#
# Claude Code uses a different schema: name and description are required, tool
# access is expressed with tools/disallowedTools, and model is a family alias.
#
# Usage: agent_to_claude.rb <agent.md>
# Writes the converted definition to stdout.

require 'yaml'
require 'date'

# Parses the frontmatter with the scalar classes that YAML can produce on its
# own. A date-like description must not be rejected as an unsafe class.
def load_frontmatter(yaml)
  if Psych::VERSION.to_i >= 4
    YAML.safe_load(yaml, permitted_classes: [Date, Time])
  else
    YAML.safe_load(yaml, [Date, Time])
  end
end

# Maps an OpenCode permission action to the Claude Code tools it covers.
TOOLS_BY_ACTION = {
  'edit' => %w[Edit Write NotebookEdit],
  'shell' => %w[Bash PowerShell],
  'subagent' => %w[Agent],
  'webfetch' => %w[WebFetch],
  'websearch' => %w[WebSearch],
  'read' => %w[Read],
  'glob' => %w[Glob],
  'grep' => %w[Grep],
  'skill' => %w[Skill]
}.freeze

# Maps a canonical model reference to a Claude Code model alias.
# Returns nil when the reference has no Claude Code equivalent.
def claude_model_alias(model)
  return nil if model.nil? || model.to_s.strip.empty?

  case model.to_s
  when /opus/i then 'opus'
  when /sonnet/i then 'sonnet'
  when /haiku/i then 'haiku'
  end
end

# Claude Code skips a subagent whose name starts with "-", contains ":",
# or is longer than 256 characters.
def valid_claude_name?(name)
  return false if name.empty? || name.start_with?('-') || name.include?(':')
  return false if name.length > 256

  true
end

# Collects the tools denied by the canonical permission rules.
# Rules that Claude Code cannot express are reported and skipped.
def denied_tools(frontmatter, source)
  denied = []

  Array(frontmatter['permissions']).each do |rule|
    action = rule['action'].to_s
    resource = rule['resource'].to_s
    effect = rule['effect'].to_s

    if effect == 'allow' && resource != '*'
      warn "#{source}: cannot express the allow rule for '#{action}' on '#{resource}' in Claude Code"
      next
    end

    next unless effect == 'deny'

    if resource != '*'
      warn "#{source}: cannot express the deny rule for '#{action}' on '#{resource}' in Claude Code"
      next
    end

    if action == '*'
      warn "#{source}: cannot express a deny-all rule in Claude Code"
      next
    end

    denied.concat(TOOLS_BY_ACTION.fetch(action, []))
  end

  denied.uniq
end

source = ARGV[0]
abort('Usage: agent_to_claude.rb <agent.md>') if source.nil? || source.empty?

contents = File.read(source)
match = contents.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)
abort("#{source}: missing YAML frontmatter") if match.nil?

begin
  frontmatter = load_frontmatter(match[1]) || {}
rescue Psych::Exception => e
  abort("#{source}: cannot parse the frontmatter: #{e.message}")
end
body = match[2]

description = frontmatter['description'].to_s
abort("#{source}: the description field is required") if description.strip.empty?

name = File.basename(source, '.md')
abort("#{source}: '#{name}' is not a valid Claude Code agent name") unless valid_claude_name?(name)

converted = {
  'name' => name,
  'description' => description
}

tools = denied_tools(frontmatter, source)
converted['disallowedTools'] = tools.join(', ') unless tools.empty?

model = claude_model_alias(frontmatter['model'])
converted['model'] = model if model

# Psych emits a YAML document start marker. The agent file needs the frontmatter
# block to be delimited by "---" on both sides, so the marker becomes the opening
# delimiter and an explicit closing delimiter is appended.
yaml = YAML.dump(converted, nil, line_width: -1).sub(/\A---\n/, '')

print "---\n#{yaml}---\n"
print "\n"
print body.strip
print "\n"
