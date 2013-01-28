# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.join File.basename(Dir.pwd), 'version'

description = <<'EOF'
Compress tweets using a variety of common substitutions in order to maximize
room for hashtags, comments on retweets, or just to fit as much information as
possible into a single tweet without compromising clarity.
EOF

Gem::Specification.new do |gem|
  gem.license       = 'GPL-3'
  gem.name          = File.basename(Dir.pwd)
  gem.version       = TweetCompressor::VERSION
  gem.authors       = [`git config user.name` ]
  gem.email         = [`git config user.email`]
  gem.description   = description
  gem.summary       = %q{Compress tweets to less than 140 characters.}
  gem.homepage      = "https://github.com/CodeGnome/#{gem.name}"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w[lib]
end
