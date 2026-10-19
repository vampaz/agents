#!/usr/bin/env ruby
# frozen_string_literal: true

# Validates that every agent definition matches the schema of the target agent.
# Usage: validate_agents.rb <dir> <schema>
#   schema "opencode" -> description, mode, and only known OpenCode V2 keys
#   schema "claude"   -> name and description, with valid Claude Code names
#
# When the directory holds a .sync_agents_manifest, only the files listed in it
# are validated. Those are the files that sync_config.sh manages.

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

dir = ARGV[0]
schema = ARGV[1]

abort('Usage: validate_agents.rb <dir> <opencode|claude>') if dir.nil? || schema.nil?

OPENCODE_KEYS = %w[description mode model permissions steps hidden color disabled request].freeze

failures = 0

manifest = File.join(dir, '.sync_agents_manifest')
paths = if File.exist?(manifest)
          File.readlines(manifest).map(&:strip).reject(&:empty?).map { |file| File.join(dir, file) }
        else
          Dir.glob(File.join(dir, '*.md')).sort
        end

paths.sort.each do |path|
  name = File.basename(path)

  contents = File.read(path)
  match = contents.match(/\A---\s*\n(.*?)\n---\s*\n(.*)\z/m)

  if match.nil?
    puts "FAIL #{name}: no frontmatter block"
    failures += 1
    next
  end

  begin
    frontmatter = load_frontmatter(match[1]) || {}
  rescue Psych::Exception => e
    puts "FAIL #{name}: cannot parse the frontmatter: #{e.message}"
    failures += 1
    next
  end

  if schema == 'opencode'
    unknown = frontmatter.keys - OPENCODE_KEYS
    if frontmatter['description'].nil?
      puts "FAIL #{name}: missing description"
      failures += 1
    elsif frontmatter['mode'] != 'subagent'
      puts "FAIL #{name}: mode is #{frontmatter['mode'].inspect}, expected subagent"
      failures += 1
    elsif !unknown.empty?
      puts "FAIL #{name}: unknown keys #{unknown.inspect}"
      failures += 1
    else
      puts "OK   #{name} model=#{frontmatter['model'].inspect} permissions=#{Array(frontmatter['permissions']).length}"
    end
  else
    agent_name = frontmatter['name'].to_s
    invalid = agent_name.empty? || agent_name.start_with?('-') || agent_name.include?(':') || agent_name.length > 256

    if frontmatter['description'].nil?
      puts "FAIL #{name}: missing description"
      failures += 1
    elsif invalid
      puts "FAIL #{name}: invalid agent name #{agent_name.inspect}"
      failures += 1
    else
      puts "OK   #{name} name=#{agent_name} model=#{frontmatter['model'].inspect} disallowed=#{frontmatter['disallowedTools'].inspect}"
    end
  end
end

exit(failures.zero? ? 0 : 1)
