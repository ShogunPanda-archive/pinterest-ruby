#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Pinterest
  # A list of errors returned by the client.
  module Errors
    # A dictionary that associates HTTP status codes to error classes.
    CODES = {
      400 => "BadRequestError",
      401 => "AuthorizationError",
      403 => "PermissionsError",
      404 => "NotFoundError",
      405 => "MethodNotAllowedError",
      408 => "TimeoutError",
      429 => "RateLimitError",
      501 => "NotImplementedError"
    }.freeze

    # The base error.
    class BaseError < RuntimeError
      attr_accessor :code, :reason, :env

      # Creates a new error.
      #
      # @param code [Fixnum] The error code.
      # @param reason [String] The error message.
      # @param env [Env] The environment.
      def initialize(code, reason, env)
        super("[#{code}] #{reason}")
        @code = code
        @reason = reason
        @env = env
      end
    end

    # Error raised in case of client errors.
    class BadRequestError < BaseError
    end

    # Error raised in case of authorization errors.
    class AuthorizationError < BaseError
    end

    # Error raised in case of permission errors.
    class PermissionsError < BaseError
    end

    # Error raised in case of invalid requested entities.
    class NotFoundError < BaseError
    end

    # Error raised in case of invalid requested actions.
    class MethodNotAllowedError < BaseError
    end

    # Error raised in case of timeouts during network operations.
    class TimeoutError < BaseError
    end

    # Error raised when rate-limited by Pinterest.
    class RateLimitError < BaseError
    end

    # Error raised in case of unimplemented requested actions.
    class NotImplementedError < BaseError
    end

    # Error raised in case of Pinterest server errors.
    class ServerError < BaseError
    end

    # Creates a new error.
    #
    # @param response [Faraday::Response] The network response.
    # @return [BaseError] A error object.
    def self.create(response)
      status = response.status
      message = response.body["error"] || response.body["message"]

      class_for_code(status).new(status, message, response.env)
    end

    # Get the class for a HTTP status code.
    #
    # @param status [Fixnum] The HTTP status code.
    # @return [Class] The class.
    def self.class_for_code(status)
      klass = ::Pinterest::Errors::CODES.fetch(status, "ServerError")
      Object.const_get("::Pinterest::Errors::#{klass}")
    end
  end
end
