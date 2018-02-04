#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Pinterest
  # A object representing a Pinterest pin.
  class Pin < Entity
    # The list of fields of the object.
    FIELDS = ["id", "link", "url", "creator", "board", "created_at", "note", "color", "counts", "media", "attribution", "image"].freeze

    attr_accessor(*FIELDS)

    # Creates a new pin object.
    #
    # @param data [Hash] The data of the new object. For a list of valid fields, see `Pinterest::Pin::FIELDS`.
    # @return [Pinterest::Board] The new pin object.
    def self.create(data)
      data["created_at"] = Pinterest::Entity.parse_timestamp(data["created_at"]) if data["created_at"]
      data = create_relationships(data)
      new(data)
    end

    # Converts the relationships (user, board, images) of the pin to a gem object.
    #
    # @param data [Hash] The raw data.
    # @return [Hash] The input data where relationships are gem objects.
    def self.create_relationships(data)
      data["creator"] = Pinterest::User.create(data["creator"]) if data["creator"]
      data["board"] = Pinterest::Board.create(data["board"]) if data["board"]
      data["image"] = Pinterest::Image.new(data["image"]) if data["image"]
      data
    end

    # Serialize the object as a Hash that can be serialized as JSON.
    #
    # @param options [Hash] The options to use to serialize.
    # @return [Hash] The serialized object.
    def as_json(options = {})
      super(::Pinterest::Pin::FIELDS, options)
    end
  end
end
