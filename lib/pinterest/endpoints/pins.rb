#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Pinterest
  module Endpoints
    # Pins related endpoints.
    module Pins
      # Returns information about a pin.
      #
      # @param pin [Fixnum|String] The pin id.
      # @param fields [Array] A list of fields to return.
      # @return [Pinterest::User] A pin object.
      def pin(pin, fields: nil)
        # Validate the pin id
        pin = validate_pin(pin)

        # Ensure only valid fields are used
        fields = ensure_pin_fields(fields)

        # Perform the request and create the pin
        data = perform_network_request(url: versioned_url("/pins/#{pin}/"), query: cleanup_params({fields: fields.join(",")})).body["data"]
        ::Pinterest::Pin.create(data)
      end

      # Creates a new pin.
      #
      # @param board [String] The board path (username/id) or id.
      # @param image [String] The image to pin.
      # @param note [String] The note to attach to the pin.
      # @param link [String] The link to attach to the pin.
      # @param fields [Array] A list of fields to return.
      # @return [Pinterest::User] The new created pin object.
      def create_pin(board, image, note: nil, link: nil, fields: nil)
        board = validate_board(board)

        # Ensure only valid fields are used
        fields = ensure_pin_fields(fields)

        # Create the payload
        payload = {note: note, board: board, link: link}

        # Add the image - Try to detect whether is a URL or a path
        payload.merge!(add_image(image))

        # Perform the request and create the pin
        data = perform_network_request(method: "POST", url: versioned_url("/pins/"), query: cleanup_params({fields: fields.join(",")}), body: payload)

        ::Pinterest::Pin.create(data.body["data"])
      end

      # Edits a pin.
      #
      # @param pin [String] The pin id.
      # @param board [String] The new board path (username/id) or id.
      # @param note [String] The new note to attach to the pin.
      # @param link [String] The new link to attach to the pin.
      # @param fields [Array] A list of fields to return.
      # @return [Pinterest::User] The updated pin object.
      def edit_pin(pin, board: nil, note: nil, link: nil, fields: nil)
        pin = validate_pin(pin)
        board = validate_board(board) if board

        # Ensure only valid fields are used
        fields = ensure_pin_fields(fields)

        # Create the payload
        payload = cleanup_params({note: note, board: board, link: link})

        # Perform the request and create the pin
        data = perform_network_request(method: "PATCH", url: versioned_url("/pins/#{pin}/"), query: cleanup_params({fields: fields.join(",")}), body: payload)
        ::Pinterest::Pin.create(data.body["data"])
      end

      # Deletes a pin.
      #
      # @param pin [String] The pin id.
      # @return [Boolean] `true` if operation succeeded, `false` otherwise.
      def delete_pin(pin)
        # Validate the board id
        pin = validate_pin(pin)

        # Perform the request
        perform_network_request(method: "DELETE", url: versioned_url("/pins/#{pin}/"))
        true
      end

      # Returns the list of pins of the authenticated user.
      #
      # @param fields [Array] A list of fields to return.
      # @param cursor [String] A cursor to paginate results, obtained by a previous call.
      # @param limit [Fixnum] The maximum number of objects to return.
      # @return [Pinterest::Collection] An collection of pin objects.
      def pins(fields: nil, cursor: nil, limit: nil)
        get_pins_collection("/me/pins/", nil, fields, cursor, limit)
      end

      # Search between of pins of the authenticated user.
      #
      # @param query [String] The query to perform.
      # @param fields [Array] A list of fields to return.
      # @param cursor [String] A cursor to paginate results, obtained by a previous call.
      # @param limit [Fixnum] The maximum number of objects to return.
      # @return [Pinterest::Collection] An collection of pin objects.
      def search_my_pins(query = "", fields: nil, cursor: nil, limit: nil)
        ensure_param(query, "You have to specify a query.")
        get_pins_collection("/me/search/pins/", {query: query}, fields, cursor, limit)
      end

      # Returns the list of pins of a board of the authenticated user.
      #
      # @param board [Fixnum|String] The board path (username/id) or id.
      # @param fields [Array] A list of fields to return.
      # @param cursor [String] A cursor to paginate results, obtained by a previous call.
      # @param limit [Fixnum] The maximum number of objects to return.
      # @return [Pinterest::Collection] An collection of pin objects.
      def board_pins(board, fields: nil, cursor: nil, limit: nil)
        validate_board(board)
        get_pins_collection("/boards/#{board}/pins/", nil, fields, cursor, limit)
      end

      # Returns the list of liked pins of the authenticated user.
      #
      # @param fields [Array] A list of fields to return.
      # @param cursor [String] A cursor to paginate results, obtained by a previous call.
      # @param limit [Fixnum] The maximum number of objects to return.
      # @return [Pinterest::Collection] An collection of pin objects.
      def likes(fields: nil, cursor: nil, limit: nil)
        get_pins_collection("/me/likes/", nil, fields, cursor, limit)
      end

      private

      # :nodoc:
      def validate_pin(pin)
        raise(ArgumentError, "You have to specify a pin or its id.") unless pin
        pin = pin.id if pin.is_a?(::Pinterest::Pin)
        pin
      end

      # :nodoc:
      def get_pins_collection(path, params, fields, cursor, limit)
        # Ensure only valid fields are used and merge params
        fields = ensure_pin_fields(fields)
        params ||= {}
        params[:fields] = fields.join(",")

        # Perform the request
        data = perform_network_request(
          url: versioned_url(path),
          query: cleanup_params(params),
          pagination: (cursor || limit), cursor: cursor, limit: limit
        )

        # Create the collection
        ::Pinterest::Collection.new(data.body, cursor, limit) { |pin| ::Pinterest::Pin.create(pin) }
      end

      # :nodoc:
      def ensure_pin_fields(fields = nil)
        # Get fields and make sure only allowed fields are kept
        fields = ensure_array(fields, ::Pinterest::Pin::FIELDS).map(&:to_s) & ::Pinterest::Pin::FIELDS

        # Replace embedded fields
        fields.map do |f|
          case f
          when "creator" then "creator(#{ensure_user_fields.join(",")})"
          when "board" then "board(#{ensure_board_fields.join(",")})"
          else f
          end
        end
      end

      # :nodoc:
      def add_image(image)
        raise(ArgumentError) if Addressable::URI.parse(image).scheme !~ /^http(s?)$/
        {image_url: image}
      rescue
        type = FastImage.type(image)
        raise(ArgumentError, "You have to specify a image URL or a valid image path.") unless type
        type = type == :jpeg ? "jpg" : type.to_s
        {image: Faraday::UploadIO.new(image, "image/#{type}")}
      end
    end
  end
end
