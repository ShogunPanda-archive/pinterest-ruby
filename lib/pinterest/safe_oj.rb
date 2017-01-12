#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

# :nodoc:
module FaradayMiddleware
  # :nodoc:
  class SafeOj < ::FaradayMiddleware::ResponseMiddleware
    dependency "oj"

    define_parser do |body|
      body.strip.empty? ? nil : Oj.load(body, mode: :compat, symbol_keys: false)
    end

    # :nodoc:
    def process_response(env)
      super(env)
    rescue Faraday::Error::ParsingError => err
      raise(Faraday::Error::ParsingError.new(err.instance_variable_get(:@wrapped_exception), env))
    end
  end
end

Faraday::Response.register_middleware safe_oj: FaradayMiddleware::SafeOj
