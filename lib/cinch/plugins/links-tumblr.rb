# -*- coding: utf-8 -*-
require 'open-uri'
require 'tumblr'
require 'yaml'
require 'cinch'
require 'cinch-storage'
require 'cinch/toolbox'

module Cinch::Plugins
  # Cinch Plugin to tumbl links from a given channel to a configured tumblr.
  class LinksTumblr
    include Cinch::Plugin

    listen_to :channel

    match /tumblr/

    self.help = 'Use .tumblr for the url/password for the channel\'s tumblr.'

    def initialize(*args)
      super
      @storage = CinchStorage.new(config[:filename] || 'yaml/tumblr.yml')
      @storage.data ||= {}
      @hostname = config[:hostname]
      @password = config[:password]
      @creds = { consumer_key:    config[:consumer_key],
                 consumer_secret: config[:consumer_secret],
                 token:           config[:token],
                 token_secret:    config[:token_secret] }
      credential_check
    end

    def execute(m)
      return if Cinch::Toolbox.sent_via_private_message?(m)

      if @hostname
        msg = "Links are available @ http://#{@hostname}"
        msg << " Password: #{@password}" unless @password.nil?
        m.user.send msg
      end
    end

    def listen(m)
      urls = URI.extract(m.message, %w(http https))
      urls.each do |url|
        @storage.data[m.channel.name] ||= []

        # Check to see if we've seen the link
        unless @storage.data[m.channel.name].include?(url)
          tumble(url, m.user.nick)

          # Store the links to try and cut down on popular urls getting
          # tumbled 20 times
          @storage.data[m.channel.name] << url
        end
        @storage.synced_save(@bot)
      end
    end

    private

    def tumble(url, nick)
      title = Cinch::Toolbox.get_page_title(url)
      # Imgur
      if url.match(%r(^https?:\/\/.*imgur\.com))
        post_image(url, title, nick)
      # Images
      elsif url.match(/\.jpg|jpeg|gif|png$/i)
        post_image(url, title, nick)
      # Youtube / Vimeo
      elsif url.match(%r(https?://[^\/]*\.?(youtube|youtu|vimeo)\.))
        post_video(url, title, nick)
      # Everything else
      else
        post_link(url, title, nick)
      end
    end

    def post_imgur(url, title, nick)
      # Imgur direct links
      imgur = url[%r(^https?://.*imgur\.com.*/([A-Za-z0-9]+\.\S{3})), 1]

      unless imgur
        # It may not be a jpg, but most browsers will read the meta regardless.
        imgur = url[%r(^https?://.*imgur\.com.*/([A-Za-z0-9]+)/?), 1] + '.jpg'
      end
      post_image("http://i.imgur.com/#{imgur}", title, nick)
    end

    def post_link(url, title = nil, nick = nil)
      document = tumblr_header(:link, title: title, tags: nick)
      document << url
      tumblr_post(document)
    end

    def post_image(url, title = nil, nick = nil)
      document = tumblr_header(:text, title: title, tags: [nick, 'image'])
      document << "<p><a href='#{url}'>" +
                  "<img src='#{url}' style='max-width: 650px;'/></a><br/>" +
                  "<a href='#{url}'>#{url}</a></p>"
      tumblr_post(document)
    end

    def post_video(url, title, nick = nil)
      document = tumblr_header(:video,
                               caption: title, tags: [nick, 'video'])
      document << url
      tumblr_post(document)
    end

    def tumblr_header(type = :text, options = {})
      opts = { type: type, hostname: @hostname }.update(options)
      doc = Psych.dump(opts)
      doc << "---\n"
      doc
    end

    def credential_check
      if @creds.values.include?(nil)
        fail ArgumentError,
             'Credentials are not set correctly, please see documentation.'
      end
    end

    def tumblr_post(doc)
      client = Tumblr::Client.new(@hostname, @creds)
      post = Tumblr::Post.load(doc)
      request = post.post(client)

      request.perform do |response|
        unless response.success?
          debug 'Something went wrong posting to Tumblr ' +
                "#{response.code} #{response.message}"
        end
      end
    end
  end
end
