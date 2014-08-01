# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cinch/plugins/links-tumblr/version'

Gem::Specification.new do |gem|
  gem.name          = 'cinch-links-tumblr'
  gem.version       = Cinch::Plugins::LinksTumblr::VERSION
  gem.authors       = ['Brian Haberer']
  gem.email         = ['bhaberer@gmail.com']
  gem.description   = %q{Cinch gem that logs every link posted in the channel to a Tumblr}
  gem.summary       = %q{Cinch Tumblr Plugin}
  gem.homepage      = 'https://github.com/bhaberer/cinch-links-tumblr'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake', '~> 10'
  gem.add_development_dependency 'rspec', '~> 3'
  gem.add_development_dependency 'coveralls', '~> 0.7'
  gem.add_development_dependency 'cinch-test', '~> 0.1', '>= 0.1.0'
  gem.add_dependency 'cinch', '~> 2'
  gem.add_dependency 'cinch-storage', '~> 1.1'
  gem.add_dependency 'cinch-toolbox', '~> 1.1'
  gem.add_dependency 'tumblr-rb', '~> 2.1', '>= 2.1.1'
end
