#!/usr/bin/env ruby

require 'bundler'
require 'yaml'
require 'chatterbot/dsl'
require 'net/http'
Bundler.require(:default)

class TestBot
  def initialize
    center = {lat: 40.7127, lng: -74.0059}
    15.times do
      post(lat: center[:lat] + rand(-5.0..5.0)/10.0, lng: center[:lng] + rand(-5.0..5.0)/10.0)
    end
  end

  def post(post_url: "/smells", lat:, lng:)
    body = {
      "smell" => {
        "content" => ["Hi smell bot!", "I love you smellbot", "You are the best", "Smells 4 eva", "smells 4 days over here"].sample,
        "lat" => lat,
        "lng" => lng,
        "user" => {
          "twitter_id" => "1231242",
          "twitter_handle" => ["parkeristyping","thephunk","stankymane","stinker"].sample,
          "name" => ["parker","evan","phil","ian","douglas"].sample
        }
      }
    }.to_json
    req = Net::HTTP::Post.new(post_url, initheader = {'Content-Type' =>'application/json'})
    req.body = body
    Net::HTTP.new("localhost", "3000").start {|http| http.request(req)}
  end
end

TestBot.new
