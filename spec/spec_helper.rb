#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "bundler/setup"

if ENV["COVERAGE"]
  require "simplecov"
  require "coveralls"

  Coveralls.wear! if ENV["CI"]

  SimpleCov.start do
    root = Pathname.new(File.dirname(__FILE__)) + ".."

    add_filter do |src_file|
      path = Pathname.new(src_file.filename).relative_path_from(root).to_s
      path !~ /^lib/
    end
  end
end

require "rubygems"
require "vcr"
require "rspec"
require "pinterest"

RSpec.configure do |config|
  config.add_formatter RSpec::Core::Formatters::ProgressFormatter if config.formatter_loader.formatters.empty?
  config.tty = true
  config.color = ENV["NO_COLOR"].nil?

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.cassette_library_dir = File.dirname(__FILE__) + "/cassettes"
  config.hook_into(:webmock)
  config.default_cassette_options = {record: :once}
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
end

# Credentials
$pinterest_client_id = "4878490596204882047"
$pinterest_client_secret = "aaa4922dadd0a08b0d767df5263e2e8987f88faa16c4079e17c10c0447c0fce0"