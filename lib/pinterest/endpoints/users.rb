#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Pinterest
  module Endpoints
    # Users related endpoints.
    module Users
      # Returns information about the authenticated user.
      #
      # @param fields [Array] A list of fields to return.
      # @return [Pinterest::User] A user object.
      def me(fields: nil)
        fields = ensure_user_fields(fields)

        # Perform request and create the user
        data = perform_network_request(url: versioned_url("/me/"), query: cleanup_params({fields: fields.join(",")}))
        ::Pinterest::User.create(data.body["data"])
      end

      # Returns information about a user.
      #
      # @param user [Fixnum|String] The username or user id.
      # @param fields [Array] A list of fields to return.
      # @return [Pinterest::User] A user object.
      def user(user, fields: nil)
        user = validate_user(user)
        fields = ensure_user_fields(fields)

        # Perform request and create the user
        data = perform_network_request(url: versioned_url("/users/#{user}/"), query: cleanup_params({fields: fields.join(",")}))
        ::Pinterest::User.create(data.body["data"])
      end

      # Returns the list of users who follow the authenticated user.
      #
      # @param fields [Array] A list of fields to return.
      # @param cursor [String] A cursor to paginate results, obtained by a previous call.
      # @param limit [Fixnum] The maximum number of objects to return.
      # @return [Pinterest::Collection] An collection of user objects.
      def followers(fields: nil, cursor: nil, limit: nil)
        get_users_collection("/me/followers/", fields, cursor, limit)
      end

      # Returns the list of users followed by the authenticated user.
      #
      # @param fields [Array] A list of fields to return.
      # @param cursor [String] A cursor to paginate results, obtained by a previous call.
      # @param limit [Fixnum] The maximum number of objects to return.
      # @return [Pinterest::Collection] An collection of user objects.
      def following_users(fields: nil, cursor: nil, limit: nil)
        get_users_collection("/me/following/users/", fields, cursor, limit)
      end

      # Follows a user.
      #
      # @param user [Fixnum|String] The username or user id.
      # @return [Boolean] `true` if operation succeeded, `false` otherwise.
      def follow_user(user)
        # Validate the user id
        user = validate_user(user)

        # Perform the request
        perform_network_request(method: "POST", body: {user: user}, url: versioned_url("/me/following/users/"))
        true
      end

      # Stops following a user.
      #
      # @param user [Fixnum|String] The username or user id.
      # @return [Boolean] `true` if operation succeeded, `false` otherwise.
      def unfollow_user(user)
        # Validate the user id
        user = validate_user(user)

        # Perform the request
        perform_network_request(method: "DELETE", url: versioned_url("/me/following/users/#{user}/"))
        true
      end

      # Returns the list of interests (topics) followed by the authenticated user.
      #
      # @param cursor [String] A cursor to paginate results, obtained by a previous call.
      # @param limit [Fixnum] The maximum number of objects to return.
      # @return [Pinterest::Collection] An collection of interest objects.
      def interests(cursor: nil, limit: nil)
        # Perform request
        data = perform_network_request(
          url: versioned_url("/me/following/interests/"),
          pagination: true, cursor: cursor, limit: limit
        )

        # Create the collection
        ::Pinterest::Collection.new(data.body, cursor, limit) { |interest| ::Pinterest::Interest.create(interest) }
      end

      # Starts following a interest.
      #
      # @param interest [Fixnum|String] The interest id.
      # @return [Boolean] `true` if operation succeeded, `false` otherwise.
      # NOTE: This is currently returning 405 on the platform. Review ASAP.
      def follow_interest(interest)
        # Validate the interest id
        raise(ArgumentError, "You have to specify a interest or its id.") unless interest
        interest = interest.id if interest.is_a?(::Pinterest::Interest)

        # Perform the request
        perform_network_request(method: "POST", query: {interest: interest}, url: versioned_url("/me/following/interests/"))
      end

      # Stops following a interest.
      #
      # @param interest [Fixnum|String] The interest id.
      # @return [Boolean] `true` if operation succeeded, `false` otherwise.
      # NOTE: This is currently returning 404 on the platform. Review ASAP.
      def unfollow_interest(interest)
        # Validate the interest id
        raise(ArgumentError, "You have to specify a interest or its id.") unless interest
        interest = interest.id if interest.is_a?(::Pinterest::Interest)

        # Perform the request
        perform_network_request(method: "DELETE", url: versioned_url("/me/following/interests/#{interest}/"))
      end

      private

      # :nodoc:
      def validate_user(user)
        raise(ArgumentError, "You have to specify a user or its id.") unless user
        user = user.id if user.is_a?(::Pinterest::User)
        user
      end

      # :nodoc:
      def get_users_collection(path, fields, cursor, limit)
        # Ensure only valid fields are used
        fields = ensure_user_fields(fields)

        # Perform the request
        data = perform_network_request(
          url: versioned_url(path),
          query: cleanup_params({fields: fields.join(",")}),
          pagination: (cursor || limit), cursor: cursor, limit: limit
        )

        # Create the collection
        ::Pinterest::Collection.new(data.body, cursor, limit) { |user| ::Pinterest::User.create(user) }
      end

      # :nodoc:
      def ensure_user_fields(fields = nil)
        # Get fields and make sure only allowed fields are kept
        ensure_array(fields, ::Pinterest::User::FIELDS).map(&:to_s) & ::Pinterest::User::FIELDS
      end
    end
  end
end
