#!/usr/bin/env bundle exec ruby

require 'rubygems'
require 'bundler/setup'
Bundler.require

Dotenv.load

# see http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/IAM.html
iam = AWS::IAM.new

puts iam.account_alias
