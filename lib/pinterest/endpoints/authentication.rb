#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Pinterest
  # Pinterest API endpoints.
  module Endpoints
    # Authentication related endpoints.
    module Authentication
      # Returns a state string needed for authorization by the Pinterest API.
      #
      # @return [String] The state.
      def authorization_state
        @state ||= SecureRandom.hex
      end

      # Returns the URL to start the authentication flow.
      #
      # @param callback_url [String] The callback where to redirect the browser when done.
      # @param scopes [Array] The list of scopes to ask for. For a list of valid fields, see `Pinterest::Client::SCOPES`.
      # @return [String] The authorization URL.
      def authorization_url(callback_url = nil, scopes = nil)
        ensure_param(client_id, "You must specify the client_id.")
        ensure_param(callback_url, "You must specify the callback_url.")
        validate_callback_url(callback_url)

        # Create the query
        query = cleanup_params({
          response_type: "code", client_id: client_id.to_s, authorization_state: authorization_state, redirect_uri: callback_url,
          scope: (ensure_array(scopes, ::Pinterest::Client::SCOPES) & ::Pinterest::Client::SCOPES).join(",") # Restrict to only valid scopes
        })

        # Create the URL
        url = Addressable::URI.parse(::Pinterest::Client::API_URL + "/oauth")
        url.query_values = query
        url.to_s
      end

      # Fetches the access token.
      #
      # @param [String] authorization_token The authorization token.
      # @return [String] The authentication token.
      def fetch_access_token(authorization_token)
        ensure_param(client_id, "You must specify the client_id.")
        ensure_param(client_secret, "You must specify the client_secret.")
        ensure_param(authorization_token, "You must specify the authorization_token.")

        # Create parameters
        query = cleanup_params({
          client_id: client_id, client_secret: client_secret,
          grant_type: "authorization_code", code: authorization_token
        })

        # Perform the request and then get the token
        response = perform_network_request(method: :post, url: versioned_url("/oauth/token"), query: query)
        @access_token = response.body["access_token"]
      end

      # Verifies the access token.
      #
      # @return [Hash] The access token informations.
      def verify_access_token
        ensure_param(client_id, "You must specify the client_id.")
        ensure_param(access_token, "You must set the access token first.")

        # Get the data
        data = perform_network_request(url: versioned_url("/oauth/inspect"), authenticated: true).body["data"]

        # Prepare for output
        create_authentication(data)
      end

      private

      # :nodoc:
      def validate_callback_url(url)
        valid =
          begin
            Addressable::URI.parse(url).scheme == "https"
          rescue
            false
          end

        raise(ArgumentError, "callback_url must be a valid HTTPS URL.") unless valid
      end

      # :nodoc:
      def create_authentication(data)
        {
          created_at: ::Pinterest::Entity.parse_timestamp(data["issued_at"]),
          scopes: data["scopes"],
          user_id: data["user_id"].to_s,
          application_id: data["app"]["id"].to_s
        }
      end
    end
  end
end
