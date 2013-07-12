# -*- coding: utf-8 -*-
require 'spec_helper'
require 'fakeweb'
FakeWeb.register_uri(:post, 'https://api.tumblr.com', response: 'foo', status: ['404', 'Not Found'])
describe Cinch::Plugins::LinksTumblr do
  include Cinch::Test

  before(:each) do
    purge_tumblr_posts
    @bot = make_bot(Cinch::Plugins::LinksTumblr, { :filename        => '/dev/null',
                                                   :hostname        => 'marvintesting.tumblr.com',
                                                   :password        => 'password',
                                                   :consumer_key    => ENV['CONSUMER_KEY'],
                                                   :consumer_secret => ENV['CONSUMER_SECRET'],
                                                   :token           => ENV['TOKEN'],
                                                   :token_secret    => ENV['TOKEN_SECRET'] })
  end

  it 'should capture links' do
    get_replies(make_message(@bot, 'http://github.com', { channel: '#foo', nick: 'bar' }))
    get_last_tumblr_post[:url].should == 'http://github.com'
  end

  it 'should capture youtube links and post them as videos' do
    get_replies(make_message(@bot, 'https://www.youtube.com/watch?v=-xiAbDkXDgg', { channel: '#foo', nick: 'bar' }))
    get_last_tumblr_post.should == 'http://github.com'
  end

  it 'should capture imgur links' do
    get_replies(make_message(@bot, 'http://imgur.com/oMndYK7', { channel: '#foo', nick: 'bar' }))
    get_last_tumblr_post.should == 'http://github.com'
  end

  it 'should capture imgur links and tumble them with title' do
    get_replies(make_message(@bot, 'http://i.imgur.com/NWq5WIq.gif', { channel: '#foo', nick: 'bar' }))
    get_last_tumblr_post.should == 'http://github.com'
  end

  it 'should capture image links' do
    get_replies(make_message(@bot, 'http://tmp.weirdo513.org/badge_3.png', { channel: '#foo', nick: 'bar' }))
    get_last_tumblr_post.should == 'http://github.com'
  end
end

def get_last_tumblr_post
  sleep 10
  JSON.parse(get_client.posts.perform.body)["response"]["posts"].last
end

def get_tumblr_posts
  client = get_client
  JSON.parse(client.posts.perform.body)["response"]["posts"]
end

def purge_tumblr_posts
  entries = get_tumblr_posts.map { |p| p["id"] }
  client  = get_client
  entries.each do |id|
    client.delete(id: id).perform do |response|
      if response.success?
        puts "Deleted #{id}"
      else
        puts "Something went wrong posting to Tumblr #{response.code} #{response.message}"
      end
    end
  end
end

def get_client
  @creds = { :consumer_key    => ENV['CONSUMER_KEY'],
             :consumer_secret => ENV['CONSUMER_SECRET'],
             :token           => ENV['TOKEN'],
             :token_secret    => ENV['TOKEN_SECRET'] }
  Tumblr::Client.new('marvintesting.tumblr.com', @creds)
end
