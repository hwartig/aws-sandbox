#!/usr/bin/env bundle exec ruby

require_relative 'config.rb'

streams.map do |stream_name|
  kinesis.describe_stream(stream_name: stream_name)
end

kinesis.put_record(
  stream_name: stream_name,
  partition_key: partition_key,
  data: Base64.strict_encode64(ARGV.first || "hello world"),
)
