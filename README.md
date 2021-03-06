# Cinch::Plugins::LinksTumblr

[![Gem Version](https://badge.fury.io/rb/cinch-links-tumblr.png)](http://badge.fury.io/rb/cinch-links-tumblr)
[![Dependency Status](https://gemnasium.com/bhaberer/cinch-links-tumblr.png)](https://gemnasium.com/bhaberer/cinch-links-tumblr)
[![Build Status](https://travis-ci.org/bhaberer/cinch-links-tumblr.png?branch=master)](https://travis-ci.org/bhaberer/cinch-links-tumblr)
[![Coverage Status](https://coveralls.io/repos/bhaberer/cinch-links-tumblr/badge.png?branch=master)](https://coveralls.io/r/bhaberer/cinch-links-tumblr?branch=master)
[![Code Climate](https://codeclimate.com/github/bhaberer/cinch-links-tumblr.png)](https://codeclimate.com/github/bhaberer/cinch-links-tumblr)

This plugin takes all links from the channel and posts them to a Tumblr.

You can optionally specify a password if you want to use a private Tumblr.

## Installation

Add this line to your application's Gemfile:

    gem 'cinch-tumblr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cinch-tumblr

## Usage

You will need to add the Plugin and config to your list first;

    @bot = Cinch::Bot.new do
      configure do |c|
        c.plugins.plugins = [Cinch::Plugins::LinksTumblr]
        c.plugins.options[Cinch::Plugins::LinksTumblr] = { :hostname         => 'whatever.tumblr.com',
                                                           :password         => 'password, if applicable' }
      end
    end

However you need to acquire Tumblr oauth credentials in order to make the Plugin work.
This is easily done using the tumblr-rb gem which is required for this plugin.

1. Run `gem install tumblr-rb`
2. Head to http://www.tumblr.com/oauth/apps to register your app and get a key and secret.
3. Run `tumblr authorize` it should pop open a window asking for the info you got from
    registering an app.
4. You will now have a file in ~/.tumblr with the info you need for the next step.

Once you have your Tumblr credentials, you need to add them to the configuration:

    @bot = Cinch::Bot.new do
      configure do |c|
        c.plugins.plugins = [Cinch::Plugins::LinksTumblr]
        c.plugins.options[Cinch::Plugins::LinksTumblr] = { :hostname         => 'whatever.tumblr.com',
                                                           :password         => 'password, if applicable',
                                                           :consumer_key     => CONSUMER_KEY,
                                                           :consumer_secret  => CONSUMER_SECRET,
                                                           :token            => TOKEN,
                                                           :token_secret     => TOKEN_SECRET }
      end
    end

That should be all you need to get the Plugin working! Users can get the Tumblr info
(hostname / password) at any time by using `!tumblr` in the channel.

By default links tumbled will be logged to `yaml/tumblr.yml`, you can change this by specifying
a different loation with `c.plugins.options[Cinch::Plugins::LinksTumblr][:filename] = NEW_PATH`.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
