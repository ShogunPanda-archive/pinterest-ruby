#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Pinterest
  # A object representing a Pinterest board.
  class Board < Entity
    # The list of fields of the object.
    FIELDS = ["id", "name", "url", "description", "creator", "created_at", "counts", "image"].freeze

    attr_accessor(*FIELDS)

    # Creates a new board object.
    #
    # @param data [Hash] The data of the new object. For a list of valid fields, see `Pinterest::Board::FIELDS`.
    # @return [Pinterest::Board] The new board object.
    def self.create(data)
      data["created_at"] = Pinterest::Entity.parse_timestamp(data["created_at"]) if data["created_at"]
      data["creator"] = Pinterest::User.create(data["creator"]) if data["creator"]
      data["image"] = Pinterest::Image.new(data["image"]) if data["image"]

      new(data)
    end

    # Serialize the object as a Hash that can be serialized as JSON.
    #
    # @param options [Hash] The options to use to serialize.
    # @return [Hash] The serialized object.
    def as_json(options = {})
      super(::Pinterest::Board::FIELDS, options)
    end
  end
end
