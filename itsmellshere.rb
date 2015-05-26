#!/usr/bin/env ruby

require 'bundler'
require 'rubygems'
require 'yaml'
require 'chatterbot/dsl'

Bundler.require(:default)

#
# this is the script for the twitter bot itsmellshere
# generated on 2015-05-26 12:14:04 -0400
#

# remove this to send out tweets
debug_mode

# remove this to update the db
no_update

# remove this to get less output when running
verbose

# here's a list of users to ignore
blacklist "abc", "def"

# here's a list of things to exclude from searches
exclude "hi", "spammer", "junk"

search "keyword" do |tweet|
 binding.pry
 reply "Hey #USER# nice to meet you!", tweet
end

replies do |tweet|
  reply "Yes #USER#, you are very kind to say that!", tweet
end
