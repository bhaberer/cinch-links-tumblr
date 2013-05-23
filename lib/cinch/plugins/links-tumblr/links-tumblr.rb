# -*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'tumblr'
require 'cinch-storage'
require 'cinch-toolbox'

module Cinch::Plugins
  class LinksTumblr
    include Cinch::Plugin

    listen_to :channel
    match /tumblr/

    self.help = 'Use .tumblr for the url and password (if any) for the channel\'s tumblr.'


    def initialize(*args)
      super
      @storage = CinchStorage.new(config[:filename] || 'yaml/tumblr.yml')
      @storage.data[:history] ||= Hash.new
      @hostname = config[:hostname] 
      @password = config[:password]
      @creds = { :consumer_key      => config[:consumer_key],
                 :consumer_secret   => config[:consumer_secret],
                 :token             => config[:token],
                 :token_secret      => config[:token_secret] }
    end

    def execute(m)
      if m.channel.nil?
        # Tumblr's are channel bound, so require the user to be in a channel
        m.user.msg "You must use that command in the main channel."
        return
      else
        if @hostname
          msg = "Links are available @ http://#{@hostname}"
          msg << " Password: #{@password}" unless @password.nil?
          m.user.send msg
        else
          debug "ERROR: Tumblr hostname has not been specified, see docs for info."
        end
      end
    end

    def listen(m)
      urls = URI.extract(m.message, ["http", "https"])
      urls.each do |url|
        @storage.data[:history][m.channel.name] ||= Hash.new

        # Check to see if we've seen the link
        unless @storage.data[:history][m.channel.name].key?(url)
          short_url = Cinch::Toolbox.shorten(url)
          title = Cinch::Toolbox.get_page_title(url)
          tumble(url, title, m.user.nick)

          # Store the links to try and cut down on popular urls getting tumbled 20 times
          @storage.data[:history][m.channel.name][url] = { :time => Time.now }
        end
      end

      if urls
        synchronize(:save_links) do
          @storage.save
        end
      end
    end

    private

    def tumble(url, title, nick)
      # Redit
      if redit = url.match(/^https?:\/\/.*imgur\.com.*\/([A-Za-z0-9]+\.\S{3})/)
        post_image("http://i.imgur.com/#{redit[1]}", title, nick)
      # Images
      elsif url.match(/\.jpg|jpeg|gif|png$/i)
        post_image(url, title, nick)
      # Youtube / Vimeo
      elsif url.match(/https?:\/\/[^\/]*\.?(youtube|youtu|vimeo)\./)
        post_video(url, nil, nick)
      # Everything else
      else
        post_link(url, title, nick)
      end
    end

    def post_link(url, title = nil, nick = nil)
      document = tumblr_header('link', { 'name' => title, 'tags' => nick })
      document << url
      tublr_post(document)
    end

    def post_quote(quote, source, nick = nil)
      document = tumblr_header('quote', { 'source' => source, 'tags' => [nick, 'twitter'] })
      document << quote
      tublr_post(document)
    end

    def post_image(url, title = nil, nick = nil)
      document = tumblr_header('text', { 'title' => title, 'tags' => [nick, 'image'] })
      document << "<p><a href='#{url}'><img src='#{url}' style='max-width: 650px;'/></a><br/><a href='#{url}'>#{url}</a></p>"
      tublr_post(document)
    end

    def post_video(url, title, nick = nil)
      document = tumblr_header('video', { 'caption' => title, 'tags' => [nick, 'video'] })
      document << url
      tublr_post(document)
    end

    def tumblr_header(type = 'text', options = {})
      opts = { 'type' => type, 'hostname' => @hostname }.update(options)
      doc = YAML::dump(opts)
      doc << "---\n"
      return doc
    end

    def tublr_post(doc)
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
