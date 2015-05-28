#!/usr/bin/env ruby

require 'bundler'
require 'yaml'
require 'json'
require 'chatterbot/dsl'
require 'net/http'
require 'pry'

consumer_key ENV["consumer_key"]
consumer_secret ENV["consumer_secret"]
secret ENV["secret"]
token ENV["token"]

def run
  last_update = get_last_update_time
  check_since(last_update)
  stream
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

def get_last_update_time
  response = Net::HTTP.start("www.itsmellshere.com", "80") do |json|
    request = Net::HTTP::Get.new "/smells/last.json"
    JSON.parse((json.request request).body)
  end
  Time.parse(response["created_at"])
end

def check_since(last_update)
  replies do |tweet|
    break if tweet.created_at <= last_update
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
