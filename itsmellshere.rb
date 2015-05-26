#!/usr/bin/env ruby

require 'bundler'
require 'yaml'
require 'chatterbot/dsl'
require 'net/http'
Bundler.require(:default)

file = YAML.load_file('itsmellshere.yml')

consumer_key file[:consumer_key]
consumer_secret file[:consumer_secret]

secret file[:secret]
token file[:token]

#
# this is the script for the twitter bot itsmellshere
# generated on 2015-05-26 12:14:04 -0400
#

# remove this to update the db
no_update

class SmellBot
  attr_accessor :last_update, :this_update, :first_time_through

  def initialize
    @last_update = nil # this to be updated
    self.parse_replies
  end

  def get_last_update
    # TODO: Add logic to get timestamp of last post from site
  end

  def parse_replies
    # search through all replies
    @first_time_through = true

    replies do |tweet|
      # End if we've gotten into old tweets
      break if @last_update && tweet.created_at < @last_update
      # if tweet does not have geolocation, reply with further instructions
      if !tweet.geo?
        if @first_time_through
          @this_update = tweet.created_at
          @first_time_through = false
        end
        reply "Thanks, but you need to enable location services and 'share precise location'. More detailed instructions here: www.placeholder.com", tweet
      else
        if @first_time_through
          @this_update = tweet.created_at
          @first_time_through = false
        end
        binding.pry
        post(tweet: tweet, user: tweet.user)
        reply "Thanks! Your smell has been added to our database. Check out the map at www.itsmellshere.com", tweet
      end
    end
    @last_update = @this_update

    sleep 60

    self.parse_replies
  end

  def post(post_url: "/smells", tweet:, user:)
    body = {
      "smell" => {
        "smell" => {
          "content" => tweet.text,
          "lat" => tweet.geo.coordinates[0],
          "lng" => tweet.geo.coordinates[1]
        },
        "user" => {
          "twitter_id" => user.id,
          "twitter_handle" => user.handle,
          "name" => user.name
        }
      }
    }.to_json
    req = Net::HTTP::Post.new(post_url, initheader = {'Content-Type' =>'application/json'})
    req.body = body
    Net::HTTP.new("localhost", "3000").start {|http| http.request(req)}
  end
end

SmellBot.new
