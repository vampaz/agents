#!/usr/bin/env ruby
# frozen_string_literal: true

# Converts a canonical agent definition into a Codex custom agent file.
#
# Codex reads standalone TOML agents from ~/.codex/agents/. Each file needs
# name, description, and developer_instructions. The model comes from the codex
# pin in agents/models.yml. Codex receives only the agents that have that pin.
# A pin such as gpt-6-luna#medium also sets the reasoning effort.
#
# A Codex custom agent inherits the parent's sandbox and approvals, so deny
# rules become instructions instead of enforced permissions.
#
# Usage:
#   agent_to_codex.rb --list <agents dir>   Lists the agents pinned for Codex.
#   agent_to_codex.rb <agent.md>            Writes the TOML agent to stdout.

require 'yaml'
require 'date'
require 'json'

# Parses the frontmatter with the scalar classes that YAML can produce on its
# own. A date-like description must not be rejected as an unsafe class.
def load_yaml(yaml)
  if Psych::VERSION.to_i >= 4
    YAML.safe_load(yaml, permitted_classes: [Date, Time])
  else
    YAML.safe_load(yaml, [Date, Time])
  end
end

def load_pins(dir)
  pins_file = File.join(dir, 'models.yml')
  File.exist?(pins_file) ? (load_yaml(File.read(pins_file)) || {}) : {}
end

# A JSON string is a valid TOML basic string for the escapes JSON produces.
def toml_string(value)
  JSON.generate(value.to_s)
end

# Maps a denied OpenCode action to the instruction that replaces it in Codex.
INSTRUCTIONS_BY_DENIED_ACTION = {
  'edit' => 'Do not create, edit, or delete files.',
  'subagent' => 'Do not launch other agents.'
}.freeze

def denied_instructions(frontmatter, source)
  instructions = []

  Array(frontmatter['permissions']).each do |rule|
    next unless rule['effect'].to_s == 'deny'

    action = rule['action'].to_s
    instruction = INSTRUCTIONS_BY_DENIED_ACTION[action]

    if rule['resource'].to_s != '*' || instruction.nil?
      warn "#{source}: cannot express the deny rule for '#{action}' on '#{rule['resource']}' in Codex"
      next
    end

    instructions << instruction
  end

  instructions.uniq
end

if ARGV[0] == '--list'
  dir = ARGV[1]
  abort('Usage: agent_to_codex.rb --list <agents dir>') if dir.nil? || dir.empty?

  load_pins(dir).each { |name, pin| puts name if pin.is_a?(Hash) && pin['codex'] }
  exit
end

source = ARGV[0]
abort('Usage: agent_to_codex.rb <agent.md>') if source.nil? || source.empty?

contents = File.read(source)
match = contents.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)
abort("#{source}: missing YAML frontmatter") if match.nil?

begin
  frontmatter = load_yaml(match[1]) || {}
rescue Psych::Exception => e
  abort("#{source}: cannot parse the frontmatter: #{e.message}")
end

name = File.basename(source, '.md')
description = frontmatter['description'].to_s
abort("#{source}: the description field is required") if description.strip.empty?

pin = load_pins(File.dirname(source)).dig(name, 'codex')
abort("#{source}: no codex model in models.yml") if pin.nil? || pin.to_s.strip.empty?

model, effort = pin.to_s.split('#', 2)
abort("#{source}: the codex pin has an empty reasoning effort") if effort&.strip&.empty?

instructions = [match[2].strip, *denied_instructions(frontmatter, source)].join("\n\n")

print "name = #{toml_string(name)}\n"
print "description = #{toml_string(description)}\n"
print "model = #{toml_string(model)}\n"
print "model_reasoning_effort = #{toml_string(effort)}\n" if effort
print "developer_instructions = #{toml_string(instructions)}\n"
