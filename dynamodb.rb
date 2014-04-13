#!/usr/bin/env bundle exec ruby

require 'rubygems'
require 'bundler/setup'
Bundler.require

Dotenv.load

# see http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/DynamoDB.html
def dynamo_db
  @dynamo_db ||= AWS::DynamoDB.new
end

def create_table_and_wait(name, *opts)
  puts "creating table '#{name}'"
  table = dynamo_db.tables.create(name, *opts)
  sleep 1 while table.status == :creating
  table
end

def get_or_create_table(name, *opts)
  if dynamo_db.tables[name].exists?
    table = dynamo_db.tables[name]
    table.load_schema
    table
  else
    create_table_and_wait(name, *opts)
  end
end

hash_key_only = get_or_create_table("hash_key_only", 1, 1, hash_key: {id: :number})

hash_key_only.items.put({id: 1, name: "Luke Skywalker"})
hash_key_only.items.put({id: 2, name: "Darth Vader"})
hash_key_only.items.put({id: 3, name: "Obi-Wan Kenoby"})

# query again by key
puts hash_key_only.items[2].attributes.to_h

# it is also possible to have binary values as hash key
user_1_id = UUIDTools::UUID.random_create
user_2_id = UUIDTools::UUID.random_create

hash_and_range = get_or_create_table("hash_and_range", 1, 1, hash_key: {user_id: :binary}, range_key: {game_id: :number})

user_1_game_1 = hash_and_range.items.put(user_id: AWS::DynamoDB::Binary.new(user_1_id.raw), game_id: 1, score: '10')
user_1_game_2 = hash_and_range.items.put(user_id: AWS::DynamoDB::Binary.new(user_1_id.raw), game_id: 2, score: '20')
user_2_game_1 = hash_and_range.items.put(user_id: AWS::DynamoDB::Binary.new(user_2_id.raw), game_id: 1, score: '15')

puts "original: #{user_1_id}, user_1_game_1: #{UUIDTools::UUID.parse_raw(user_1_game_1.hash_value).to_s}"

user_1_games_refs = hash_and_range.items.query(hash_value: AWS::DynamoDB::Binary.new(user_1_id.raw))
# items might come back in a different order than requested
user_1_games = hash_and_range.batch_get(:all, user_1_games_refs)

puts user_1_games.to_a.map(&:to_h)

hash_key_only.delete
hash_and_range.delete
