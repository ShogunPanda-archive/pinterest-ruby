#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Pinterest
  module Endpoints
    # Boards related endpoints.
    module Boards
      # Returns information about a board.
      #
      # @param board [String] The board path (username/id) or user id.
      # @param fields [Array] A list of fields to return.
      # @return [Pinterest::Board] A board object.
      def board(board, fields: nil)
        # Validate the board id
        board = validate_board(board)

        # Ensure only valid fields are used
        fields = ensure_board_fields(fields)

        # Perform the request and create the board
        data = perform_network_request(url: versioned_url("/boards/#{board}/"), query: cleanup_params({fields: fields.join(",")})).body["data"]
        ::Pinterest::Board.create(data)
      end

      # Returns the list of the boards of the authenticated user. Pagination is not supported by Pinterest API.
      #
      # @param fields [Array] A list of fields to return.
      # @return [Pinterest::Collection] An collection of board objects.
      def boards(fields: nil)
        get_boards_collection("/me/boards/", nil, fields)
      end

      # Creates a new board.
      #
      # @param name [String] The board name.
      # @param description [String] The board description.
      # @param fields [Array] A list of fields to return.
      # @return [Pinterest::Board] The created board object.
      def create_board(name, description = "", fields: nil)
        # Validate name
        ensure_param(name, "You have to specify the board name.")

        # Ensure only valid fields are used
        fields = ensure_board_fields(fields)

        # Create the board
        data = perform_network_request(
          method: "POST", url: versioned_url("/boards/"),
          query: cleanup_params({fields: fields.join(",")}),
          body: cleanup_params({name: name, description: description})
        )

        # Wrap in a object
        ::Pinterest::Board.create(data.body["data"])
      end

      # Edits a board.
      #
      # @param board [Fixnum] The board id.
      # @param name [String] The new board name.
      # @param description [String] The new board description.
      # @param fields [Array] A list of fields to return.
      # @return [Pinterest::Board] The updated board object.
      def edit_board(board, name: nil, description: nil, fields: nil)
        # Validate the board id
        raise(ArgumentError, "You have to specify a board or its id.") unless board
        board = board.id if board.is_a?(::Pinterest::Board)

        # Ensure only valid fields are used
        fields = ensure_board_fields(fields)

        # Create the board
        data = perform_network_request(
          method: "PATCH", url: versioned_url("/boards/#{board}/"),
          query: cleanup_params(fields: fields.join(",")),
          body: cleanup_params({name: name, description: description})
        )

        # Wrap in a object
        ::Pinterest::Board.create(data.body["data"])
      end

      # Deletes a board.
      #
      # @param board [Fixnum] The board id.
      # @return [Boolean] `true` if operation succeeded, `false` otherwise.
      def delete_board(board)
        # Validate the board id
        board = validate_board(board)

        # Perform the request
        perform_network_request(method: "DELETE", url: versioned_url("/boards/#{board}/"))
        true
      end

      # Search between of boards of the authenticated user.
      #
      # @param query [String] The query to perform.
      # @param fields [Array] A list of fields to return.
      # @param cursor [String] A cursor to paginate results, obtained by a previous call.
      # @param limit [Fixnum] The maximum number of objects to return.
      # @return [Pinterest::Collection] An collection of board objects.
      def search_my_boards(query, fields: nil, cursor: nil, limit: nil)
        ensure_param(query, "You have to specify a query.")
        get_boards_collection("/me/search/boards/", {query: query}, fields, cursor, limit)
      end

      # Returns the list of boards of suggested boards for the authenticated user.
      #
      # @param fields [Array] A list of fields to return.
      # @param cursor [String] A cursor to paginate results, obtained by a previous call.
      # @param limit [Fixnum] The maximum number of objects to return.
      # @return [Pinterest::Collection] An collection of board objects.
      def suggested_boards(fields: nil, cursor: nil, limit: nil)
        get_boards_collection("/me/boards/suggested/", nil, fields, cursor, limit)
      end

      # Returns the list of boards followed by the authenticated user.
      #
      # @param fields [Array] A list of fields to return.
      # @param cursor [String] A cursor to paginate results, obtained by a previous call.
      # @param limit [Fixnum] The maximum number of objects to return.
      # @return [Pinterest::Collection] An collection of board objects.
      def following_boards(fields: nil, cursor: nil, limit: nil)
        get_boards_collection("/me/following/boards/", nil, fields, cursor, limit)
      end

      # Follows a board.
      #
      # @param board [String] The board id.
      # @return [Boolean] `true` if operation succeeded, `false` otherwise.
      def follow_board(board)
        # Validate the board id
        board = validate_board(board)

        # Perform the request
        perform_network_request(method: "POST", query: {board: board}, url: versioned_url("/me/following/boards/"))
        true
      end

      # Stop following a board.
      #
      # @param board [String] The board id.
      # @return [Boolean] `true` if operation succeeded, `false` otherwise.
      def unfollow_board(board)
        # Validate the board id
        board = validate_board(board)

        # Perform the request
        perform_network_request(method: "DELETE", url: versioned_url("/me/following/boards/#{board}/"))
        true
      end

      private

      # :nodoc:
      def get_boards_collection(path, params, fields, cursor = nil, limit = nil)
        # Ensure only valid fields are used and merge params
        fields = ensure_board_fields(fields)
        params ||= {}
        params[:fields] = fields.join(",")

        # Perform the request
        data = perform_network_request(
          url: versioned_url(path),
          query: cleanup_params(params),
          pagination: (cursor || limit), cursor: cursor, limit: limit
        )

        # Create the collection
        ::Pinterest::Collection.new(data.body, cursor, limit) { |board| ::Pinterest::Board.create(board) }
      end

      # :nodoc:
      def validate_board(board)
        raise(ArgumentError, "You have to specify a board or its id.") unless board
        board = board.id if board.is_a?(::Pinterest::Board)
        board
      end

      # :nodoc:
      def ensure_board_fields(fields = nil)
        # Get fields and make sure only allowed fields are kept
        fields = ensure_array(fields, ::Pinterest::Board::FIELDS).map(&:to_s) & ::Pinterest::Board::FIELDS

        # Replace embedded fields
        fields.map { |f| f == "creator" ? "creator(#{ensure_user_fields.join(",")})" : f }
      end
    end
  end
end
