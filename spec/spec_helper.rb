require 'coveralls'
Coveralls.wear!
if File::exist? File.join(File.dirname(__FILE__), "secret.rb")
  require 'secret'
end
require 'cinch-links-tumblr'
require 'cinch/test'
