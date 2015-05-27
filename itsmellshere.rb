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
    @last_update = Time.now #get_last_update_time
    self.parse_replies
  end

  def get_last_update_time
    Net::HTTP.start("www.itsmellshere.com", "80") do |json|
      request = Net::HTTP::Get.new "/smells/last.json"
      response = JSON.parse((json.request request).body)
    end
    Time.parse(response["created_at"])
  end

  def parse_replies
    # search through all replies
    @first_time_through = true

    replies do |tweet|
      # End if we've gotten into old tweets
      break if tweet.created_at < @last_update
      # if tweet does not have geolocation, reply with further instructions
      if !tweet.geo?
        if @first_time_through
          @this_update = tweet.created_at
          @first_time_through = false
        end
        reply "#USER# That stinks! You need to enable location services. Instructions here: itsmellshere.com/enable_location", tweet
      else
        if @first_time_through
          @this_update = tweet.created_at
          @first_time_through = false
        end
        post(tweet: tweet, user: tweet.user)
        reply "#USER# Thanks! Your smell was added. Check out the map at www.itsmellshere.com", tweet
      end
    end

    if @this_update
      @last_update = @this_update
    end

    sleep 60

    self.parse_replies
  end

  def post(post_url: "/smells", tweet:, user:)
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

SmellBot.new


## Script for testing rails app websockets
class PotentialSmellBot

  def initialize
    @time = Time.now
    self.getTweets
  end

  def getTweets
    geo_tweets = []
    search("it smells") do |tweet|
      if tweet.geo? && tweet.geo.coordinates != [0.0, 0.0] # && tweet.created_at > @time
        geo_tweets << tweet
        @time = tweet.created_at
      end
    end
    puts "There were #{geo_tweets.length} tweets with valid geographic info"
    geo_tweets.each do |tweet|
      post(tweet: tweet, user:tweet.user)
    end

    sleep 180

    self.getTweets
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

# PotentialSmellBot.new

class TestBot
  def initialize
    center = {lat: 40.7127, lng: -74.0059}
    100.times do
      post(lat: center[:lat] + rand(-5.0..5.0)/10.0, lng: center[:lng] + rand(-5.0..5.0)/10.0)
    end
  end

  def post(post_url: "/smells", lat:, lng:)
    body = {
      "smell" => {
        "smell" => {
          "lat" => lat,
          "lng" => lng
        }
      }
    }.to_json
    req = Net::HTTP::Post.new(post_url, initheader = {'Content-Type' =>'application/json'})
    req.body = body
    Net::HTTP.new("localhost", "3000").start {|http| http.request(req)}
  end
end

# TestBot.new
