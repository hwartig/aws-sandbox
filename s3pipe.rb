#!/usr/bin/env bundle exec ruby
require 'rubygems'
require 'bundler/setup'
Bundler.require

Dotenv.load

def usage
  puts "Usage:
    ./s3pipe.rb s3://bucket/source > dest
    cat source | ./s3pipe.rb s3://bucket/dest"
  exit
end

begin
  uri = URI.parse(ARGV.first)
  usage if uri.scheme != 's3'
rescue
  usage
end

s3 = AWS::S3.new

object = s3.buckets[uri.host].objects[uri.path[1..-1]]

if $stdin.tty?
  object.read do |chunk|
    $stdout.write(chunk)
  end
else
  buffer_size = [
    AWS.config.s3_multipart_threshold,
    AWS.config.s3_multipart_min_part_size
  ].max

  buffer = $stdin.read(buffer_size)
  if $stdin.eof?
    object.write(buffer)
  else
    object.multipart_upload do |upload|
      # make sure we end multipart upload even if we get SIGTERM
      at_exit { upload.complete }

      begin
        upload.add_part(buffer)
      end while $stdin.read(buffer_size, buffer)
    end
  end
end
