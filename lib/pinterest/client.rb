#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Pinterest
  # A Pinterest API client.
  #
  # @attribute access_token
  #   @return [String] The access token.
  # @attribute client_id [String]
  #   @return The client id.
  # @attribute client_secret [String]
  #   @return The client secret.
  # @attribute verbose [Boolean]
  #   @return If log requests.
  # @attribute connection_setup [Proc]
  #   @return Additional code to execute on the connection object.
  class Client
    # The Pinterest API Root URL.
    API_URL = "https://api.pinterest.com".freeze

    # The Pinterest API version.
    API_VERSION = "v1".freeze

    # The allowed authorization scopes.
    SCOPES = ["read_public", "write_public", "read_relationships", "write_relationships"].freeze

    # The maximum number of results to return by default.
    DEFAULT_LIMIT = 50

    attr_accessor :client_id, :client_secret, :access_token, :verbose, :connection

    # Creates a new client.
    #
    # @param access_token [String] The access token.
    # @param client_id [String] The client id.
    # @param client_secret [String] The client secret.
    # @param verbose [Boolean] If log requests.
    # @param connection_setup [Proc] Additional code to execute on the connection object.
    def initialize(access_token: nil, client_id: nil, client_secret: nil, verbose: false, &connection_setup)
      @client_id = client_id
      @client_secret = client_secret
      @access_token = access_token
      @verbose = verbose

      ensure_connection(connection_setup)
    end

    include Pinterest::Endpoints::Authentication
    include Pinterest::Endpoints::Users
    include Pinterest::Endpoints::Pins
    include Pinterest::Endpoints::Boards

    private

    # :nodoc:
    def ensure_connection(setup = nil)
      setup ||= ->(c) { default_connection_setup(c) }
      @connection ||= Faraday.new(url: ::Pinterest::Client::API_URL, &setup)
    end

    # :nodoc:
    def ensure_array(subject, default = [])
      subject = (subject ? [subject] : [default]).flatten unless subject.is_a?(Array)
      subject
    end

    # :nodoc:
    def ensure_param(param, error = nil)
      valid = param && !param.to_s.strip.empty?
      raise(ArgumentError, error) if error && !valid
      valid
    end

    # :nodoc:
    def default_connection_setup(c)
      c.request(:multipart)
      c.request(:url_encoded)
      c.response(:safe_oj)
      c.response(:logger) if verbose

      c.use(FaradayMiddleware::FollowRedirects)
      c.adapter(Faraday.default_adapter)
    end

    # :nodoc:
    def cleanup_params(params)
      params.reject { |_, v| !ensure_param(v) }
    end

    # :nodoc:
    # rubocop:disable Metrics/ParameterLists
    def perform_network_request(method: "GET", url: "/", query: {}, body: {}, headers: {}, authenticated: true, pagination: false, **args, &additional)
      response = connection.send(method.downcase) do |request|
        # Setup URL and headers
        setup_headers(request, url, headers, query, authenticated)

        # Handle pagination
        handle_pagination(request, args) if pagination

        # Add the body
        request.body = body

        # Run user callback
        yield(request) if additional
      end

      # Perform the call
      raise(::Pinterest::Errors.create(response)) unless response.success?
      response
    rescue Faraday::ParsingError => e
      handle_network_error(e)
    end

    # :nodoc:
    def handle_network_error(e)
      code = e.response.status
      message = /<h1>(.+?)<\/h1>/mi.match(e.response.body)

      raise(::Pinterest::Errors.class_for_code(code).new(code, message ? message[1] : "Invalid response from the server.", e.response))
    end

    # :nodoc:
    def handle_pagination(request, args)
      limit = args[:limit].to_i
      limit = DEFAULT_LIMIT if limit < 1

      request.params[:cursor] = args[:cursor] if args[:cursor]
      request.params[:limit] = limit
    end

    # :nodoc:
    def setup_headers(request, url, headers, query, authenticated)
      request.url(url)
      request.headers["Authorization"] = "Bearer #{access_token}" if authenticated
      request.headers.merge!(headers)
      request.params.merge!(query)
    end

    # :nodoc:
    def versioned_url(url)
      "/#{::Pinterest::Client::API_VERSION}/#{url.gsub(/^\//, "")}"
    end
  end
end
