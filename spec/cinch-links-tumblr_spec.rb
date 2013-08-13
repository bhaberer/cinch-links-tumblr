# -*- coding: utf-8 -*-
require 'cinch'
require 'spec_helper'
describe Cinch::Plugins::LinksTumblr do
  include Cinch::Test

  before(:all) do
    @bot = build_bot('password')
  end

  after(:all) do
    purge_tumblr_posts
  end

  it 'should return the links url and password if one is defined' do
    get_replies(make_message(@bot, '!tumblr', { channel: '#foo', nick: 'bar' })).
      first.text.should == "Links are available @ http://marvintesting.tumblr.com Password: password"
  end

  it 'should not send url and password if sent via pm' do
    get_replies(make_message(@bot, '!tumblr')).
      first.text.should == "You must use that command in the main channel."
  end

  it 'should not return a password if one is not defined' do
    get_replies(make_message(build_bot, '!tumblr', { channel: '#foo', nick: 'bar' })).
      first.text.should == "Links are available @ http://marvintesting.tumblr.com"
  end    

  it 'should capture links' do
    get_replies(make_message(@bot, 'http://github.com', { channel: '#foo', nick: 'bar' }))
    post = get_last_tumblr_post
    post['url'].should == 'http://github.com'
    post["type"].should == 'link'
  end

  it 'should capture youtube links and post them as videos' do
    get_replies(make_message(@bot, 'https://www.youtube.com/watch?v=-xiAbDkXDgg', { channel: '#foo', nick: 'bar' }))
    post = get_last_tumblr_post
    post['caption'].should == '<p>Lo Pan Style (Gangnam Style Parody) Official - YouTube</p>'
    post['tags'].should == ['bar', 'video']
    post['type'].should == 'video'
  end

  it 'should capture imgur links' do
    get_replies(make_message(@bot, 'http://imgur.com/oMndYK7', { channel: '#foo', nick: 'bar' }))
    post = get_last_tumblr_post
    post['title'].should == 'Anybody with a cat will relate. - Imgur'
    post['type'].should == 'text'
  end

  it 'should capture imgur links and tumble them with title' do
    get_replies(make_message(@bot, 'http://i.imgur.com/NWq5WIq.gif', { channel: '#foo', nick: 'bar' }))
    post = get_last_tumblr_post
    post['title'].should == '"ball, ball, ball, BALL!!" - Corgi - Imgur'
    post['type'].should == 'text'
  end

  it 'should capture image links' do
    get_replies(make_message(@bot, 'http://tmp.weirdo513.org/choc.jpg', { channel: '#foo', nick: 'bar' }))
    post = get_last_tumblr_post
    post['title'].should == 'Image from http://tmp.weirdo513.org'
    post['type'].should == 'text'
  end
end

def get_last_tumblr_post
  sleep 60
  posts = JSON.parse(get_client.posts.perform.body)["response"]["posts"][0]
end

def get_tumblr_posts
  client = get_client
  JSON.parse(client.posts.perform.body)["response"]["posts"]
end

def purge_tumblr_posts
  client  = get_client
  entries = JSON.parse(client.posts.perform.body)["response"]["posts"]
  entries.map! { |p| p["id"] }

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
  @creds = { consumer_key:    ENV['CONSUMER_KEY'],
             consumer_secret: ENV['CONSUMER_SECRET'],
             token:           ENV['TOKEN'],
             token_secret:    ENV['TOKEN_SECRET'] }
  Tumblr::Client.new('marvintesting.tumblr.com', @creds)
end

def build_bot(password = nil)
  conf =  { filename:        '/dev/null',
            hostname:        'marvintesting.tumblr.com',
            consumer_key:    ENV['CONSUMER_KEY'],
            consumer_secret: ENV['CONSUMER_SECRET'],
            token:           ENV['TOKEN'],
            token_secret:    ENV['TOKEN_SECRET'] }
  conf[:password] = password unless password.nil?
  
  make_bot(Cinch::Plugins::LinksTumblr, conf)
end
