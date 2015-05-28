#!/usr/bin/env ruby

require 'yaml'
require 'net/http'
require 'json'
require 'chatterbot/dsl'

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
  in_body_coords = tweet.text.match(/Lat:(-?\d+.\d+), Lng:(-?\d+.\d+)/)
  if !tweet.geo? && !in_body_coords
    reply "#USER# That stinks! You need to enable location services. Instructions: www.itsmellshere.com/enable_location", tweet
  else
    if in_body_coords
      post_smell(tweet: tweet, user: tweet.user, coords: [in_body_coords[0], in_body_coords[1]])
    else
      post_smell(tweet: tweet, user: tweet.user)
    end
    reply "#USER# Thanks! Your smell was added. Check out the map at www.itsmellshere.com", tweet
  end
end

def post_smell(post_url: "/smells", tweet:, user:, coords: nil)
  if coords
    lat = coords[0]
    lng = coords[1]
  else
    lat = tweet.geo.coordinates[0]
    lng = tweet.geo.coordinates[1]
  end
  body = {
    "smell" => {
      "content" => tweet.text,
      "lat" => lat,
      "lng" => lng,
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

run
