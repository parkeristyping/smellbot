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

# remove this to send out tweets
#debug_mode

# remove this to update the db
no_update

# remove this to get less output when running
#verbose

# here's a list of users to ignore
#blacklist "abc", "def"

# here's a list of things to exclude from searches
#exclude "hi", "spammer", "junk"


# TODO: Get time at initialization

loop do
  # search through all replies (TODO: since last check)
  replies do |tweet|
    # if tweet does not have geolocation, reply with further instructions if tweet does not have geolocation
    if !tweet.geo?
      # reply "Thanks, but you need to enable location services and 'share precise location'. More detailed instructions here: www.placeholder.com"
    else
      binding.pry
      post(tweet: tweet, user: tweet.user)
      # reply "Thanks! Your smell has been added to our database. Check out the map at www.itsmellshere.com"
    end
  end

  # sleep 60 seconds
  sleep 60

  # TODO: update time
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
  Net::HTTP.new("localhost", "3000").start {|http| http.request(req) }

end
