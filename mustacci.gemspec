# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mustacci/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["marceldegraaf", "iain"]
  gem.email         = ["iain@iain.nl"]
  gem.description   = %q{Stupidly Simple Continuous Integration}
  gem.summary       = %q{Stupidly Simple Continuous Integration}
  gem.homepage      = "https://github.com/marceldegraaf/mustacci"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mustacci"
  gem.require_paths = ["lib"]
  gem.version       = Mustacci::VERSION

  gem.add_runtime_dependency "sinatra"
  gem.add_runtime_dependency "slim"
  gem.add_runtime_dependency "sass"
  gem.add_runtime_dependency "compass"
  gem.add_runtime_dependency "zmq"
  gem.add_runtime_dependency "thin"
  gem.add_runtime_dependency "rake"
  gem.add_runtime_dependency "faye"
  gem.add_runtime_dependency "foreman"
  gem.add_runtime_dependency "couchrest"
  gem.add_runtime_dependency "hashie"
  gem.add_runtime_dependency "thor"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "shotgun"
end
