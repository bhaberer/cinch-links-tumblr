# -*- coding: utf-8 -*-
require 'spec_helper'

describe Cinch::Plugins::LinksTumblr do
  include Cinch::Test

  before(:each) do
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
    @bot.plugins.first.storage.data['#foo'].
      should include 'http://github.com'
  end
end
