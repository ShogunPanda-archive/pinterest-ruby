#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require File.expand_path("../lib/pinterest/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name = "pinterest-ruby"
  gem.version = Pinterest::Version::STRING
  gem.homepage = "https://github.com/ShogunPanda/pinterest-ruby"
  gem.summary = "Pinterest API wrapper for Ruby."
  gem.description = "Pinterest API wrapper for Ruby."
  gem.rubyforge_project = "pinterest-ruby"

  gem.authors = ["Shogun"]
  gem.email = ["shogun@cowtech.it"]
  gem.license = "MIT"

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.2"

  gem.add_dependency("addressable", "~> 2.5")
  gem.add_dependency("faraday", "~> 0.10")
  gem.add_dependency("faraday_middleware", "~> 0.10")
  gem.add_dependency("fastimage", "~> 2.0")
  gem.add_dependency("oj", "~> 2.18")
end
