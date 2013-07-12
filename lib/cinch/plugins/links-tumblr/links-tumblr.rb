# -*- coding: utf-8 -*-
require 'open-uri'
require 'tumblr'
require 'cinch'
require 'cinch-storage'
require 'cinch/toolbox'

module Cinch::Plugins
  class LinksTumblr
    include Cinch::Plugin

    listen_to :channel

    match /tumblr/

    self.help = 'Use .tumblr for the url and password (if any) for the channel\'s tumblr.'

    def initialize(*args)
      super
      @storage = CinchStorage.new(config[:filename] || 'yaml/tumblr.yml')
      @storage.data ||= {}
      @hostname = config[:hostname]
      @password = config[:password]
      @creds = { :consumer_key      => config[:consumer_key],
                 :consumer_secret   => config[:consumer_secret],
                 :token             => config[:token],
                 :token_secret      => config[:token_secret] }
      credential_check
    end

    def execute(m)
      return if Cinch::Toolbox.sent_via_private_message?(m)

      if @hostname
        msg = "Links are available @ http://#{@hostname}"
        msg << " Password: #{@password}" unless @password.nil?
        m.user.send msg
      else
        debug "ERROR: Tumblr hostname has not been specified, see docs for info."
      end
    end

    def listen(m)
      urls = URI.extract(m.message, ["http", "https"])
      urls.each do |url|
        @storage.data[m.channel.name] ||= []

        # Check to see if we've seen the link
        unless @storage.data[m.channel.name].include?(url)
          tumble(url, m.user.nick)

          # Store the links to try and cut down on popular urls getting tumbled 20 times
          @storage.data[m.channel.name] << url
        end
        @storage.synced_save(@bot)
      end

    end

    private

    def tumble(url, nick)
      title = Cinch::Toolbox.get_page_title(url)
      # Redit
      if redit = url.match(/^https?:\/\/.*imgur\.com.*\/([A-Za-z0-9]+\.\S{3})/)
        post_image("http://i.imgur.com/#{redit[1]}", title, nick)
      # Images
      elsif url.match(/\.jpg|jpeg|gif|png$/i)
        post_image(url, title, nick)
      # Youtube / Vimeo
      elsif url.match(/https?:\/\/[^\/]*\.?(youtube|youtu|vimeo)\./)
        post_video(url, title, nick)
      # Everything else
      else
        post_link(url, title, nick)
      end
    end

    def post_link(url, title = nil, nick = nil)
      document = tumblr_header('link', { 'title' => title, 'tags' => nick })
      document << url
      tumblr_post(document)
    end

    def post_quote(quote, source, nick = nil)
      document = tumblr_header('quote', { 'source' => source, 'tags' => [nick, 'twitter'] })
      document << quote
      tumblr_post(document)
    end

    def post_image(url, title = nil, nick = nil)
      document = tumblr_header('text', { 'title' => title, 'tags' => [nick, 'image'] })
      document << "<p><a href='#{url}'><img src='#{url}' style='max-width: 650px;'/></a><br/><a href='#{url}'>#{url}</a></p>"
      tumblr_post(document)
    end

    def post_video(url, title, nick = nil)
      document = tumblr_header('video', { 'caption' => title, 'tags' => [nick, 'video'] })
      document << url
      tumblr_post(document)
    end

    def tumblr_header(type = 'text', options = {})
      opts = { 'type' => type, 'hostname' => @hostname }.update(options)
      doc = YAML::dump(opts)
      doc << "---\n"
      return doc
    end

    def credential_check
      @creds.values.each do |c|
        raise ArguementError if c.nil?
      end
    end

    def tumblr_post(doc)
      client = Tumblr::Client.new(@hostname, @creds)
      post = Tumblr::Post.load(doc)
      request = post.post(client)

      request.perform do |response|
        if response.success?
          debug "Successfully posted to Tumblr"
        else
          debug "Something went wrong posting to Tumblr #{response.code} #{response.message}"
        end
      end
    end
  end
end
