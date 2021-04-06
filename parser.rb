#!/usr/bin/env ruby
# frozen_string_literal: true
require 'digest'
require 'json'
require 'bullet_log_parser'

stacks = {}

BulletLogParser.parse($stdin) do |ast|
  key = Digest::MD5.hexdigest(ast[:stack].to_json)

  stacks[key] ||= ast
  stacks[key][:count] ||= 0
  stacks[key][:count] += 1
end


output = stacks.sort_by { |k, v| -v[:count] }.map do |key, result|
  title = "#{result[:details].first} #{result[:count]} entries"
  detection = result[:detection]
  request = result[:request]
  stack = result[:stack].map { |s| "#{s[:filename]}:#{s[:lineno]} #{s[:message]}"}.join("\n")

  [title, detection, request, "", stack, ""].join("\n")
end.join("\n\n")

puts output
