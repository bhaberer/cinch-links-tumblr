# -*- coding: utf-8 -*-
require 'spec_helper'

describe Cinch::Plugins::LinksLogger do
  include Cinch::Test

  before(:each) do
    @bot = make_bot(Cinch::Plugins::LinksLogger, { :filename => '/dev/null' })
  end

  it 'should capture links' do
    get_replies(make_message(@bot, 'http://github.com', { channel: '#foo', nick: 'bar' }))
    @bot.plugins.first.storage.data['#foo'].keys.first.
      should == 'http://github.com'
  end

  it 'should capture links count' do
    15.times { get_replies(make_message(@bot, 'http://github.com', { channel: '#foo' })) }
    links = @bot.plugins.first.storage.data['#foo']
    puts "\n\n#{links}\n\n"
    links.length.should == 1
    links.values.first.count.should == 15
  end

  it 'should not capture malformed URLS' do
    get_replies(make_message(@bot, 'htp://github.com', { channel: '#foo', nick: 'bar' }))
    get_replies(make_message(@bot, 'http/github.com', { channel: '#foo', nick: 'bar' }))
    @bot.plugins.first.storage.data['#foo'].
      should be_nil
  end

  it 'should allow users to get a list of recently linked URLS' do
    get_replies(make_message(@bot, 'http://github.com', { channel: '#foo', nick: 'bar' }))
    replies = get_replies(make_message(@bot, '!links', { channel: '#foo', nick: 'test' }))
    replies.first.text.should == 'Recent Links in #foo'
    replies.last.text.should == 'http://github.com - GitHub · Build software better, together.'
  end
end
