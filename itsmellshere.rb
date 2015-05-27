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

  def initialize
    @last_update = get_last_update_time
  end

  def run
    check_since_last_update
    stream
  end

  private
  def get_last_update_time
    response = Net::HTTP.start("www.itsmellshere.com", "80") do |json|
      request = Net::HTTP::Get.new "/smells/last.json"
      JSON.parse((json.request request).body)
    end
    Time.parse(response["created_at"])
  end

  def check_since_last_update
    replies do |tweet|
      break if tweet.created_at <= @last_update
      handle tweet
    end
  end

  def stream
    streaming do
      replies do |tweet|
        handle tweet
      end
    end
  end

  def handle(tweet)
    if !tweet.geo?
      reply "#USER# That stinks! You need to enable location services. Instructions: www.itsmellshere.com/enable_location", tweet
    else
      post_smell(tweet: tweet, user: tweet.user)
      reply "#USER# Thanks! Your smell was added. Check out the map at www.itsmellshere.com", tweet
    end
  end

  def post_smell(post_url: "/smells", tweet:, user:)
    body = {
      "smell" => {
        "content" => tweet.text,
        "lat" => tweet.geo.coordinates[0],
        "lng" => tweet.geo.coordinates[1],
        "user" => {
          "twitter_id" => user.id,
          "twitter_handle" => user.handle,
          "name" => user.name
        }
      }
    }.to_json
    req = Net::HTTP::Post.new(post_url, initheader = {'Content-Type' =>'application/json'})
    req.body = body
    Net::HTTP.new("www.itsmellshere.com", "80").start {|http| http.request(req)}
  end
end

smellbot = SmellBot.new
smellbot.run
