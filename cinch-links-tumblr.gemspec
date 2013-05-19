# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cinch/plugins/links-tumblr/version'

Gem::Specification.new do |gem|
  gem.name          = "cinch-links-tumblr"
  gem.version       = Cinch::Plugins::LinksTumblr::VERSION
  gem.authors       = ["Brian Haberer"]
  gem.email         = ["bhaberer@gmail.com"]
  gem.description   = %q{Cinch gem that logs every link posted in the channel to a Tumblr}
  gem.summary       = %q{Cinch Tumblr Plugin}
  gem.homepage      = "https://github.com/bhaberer/cinch-links-tumblr"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('cinch-storage', '>= 0.0.1')
  gem.add_dependency('cinch-toolbox', '>= 0.0.5')
  gem.add_dependency('cinch',         '>= 2.0.0')
  gem.add_dependency('tumblr-rb',     '>= 2.0.0')
  gem.add_dependency('weary',         '>= 1.1.3')
end
