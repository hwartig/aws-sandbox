#!/usr/bin/env bundle exec ruby

require_relative 'config.rb'

@shard_iterator = kinesis.get_shard_iterator(
  stream_name: stream_name,
  shard_id: 'shardId-000000000000',
  shard_iterator_type: 'TRIM_HORIZON',
)[:shard_iterator]

while true do
  result = kinesis.get_records(
    shard_iterator: @shard_iterator
  )

  @shard_iterator = result[:next_shard_iterator]
  result[:records].each do |record|
    puts Base64.strict_decode64(record[:data])
  end
  sleep 1
end
