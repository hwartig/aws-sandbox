require 'rubygems'
require 'bundler/setup'
Bundler.require

Dotenv.load

def kinesis
  @kinesis ||= AWS::Kinesis.new.client
end

def stream_name
  ENV["KINESIS_STREAM_NAME"] || 'test-stream'
end

def partition_key
  ENV["KINESIS_PARTITION"] || 'partition'
end

def streams
  kinesis.list_streams[:stream_names]
end
