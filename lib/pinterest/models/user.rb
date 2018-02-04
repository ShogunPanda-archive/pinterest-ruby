#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Pinterest
  # A object representing a Pinterest user.
  class User < Entity
    # The list of fields of the object.
    FIELDS = ["id", "username", "first_name", "last_name", "bio", "created_at", "counts", "image"].freeze

    attr_accessor(*FIELDS)

    # Creates a new user object.
    #
    # @param data [Hash] The data of the new object. For a list of valid fields, see `Pinterest::User::FIELDS`.
    # @return [Pinterest::Board] The new user object.
    def self.create(data)
      data["created_at"] = Pinterest::Entity.parse_timestamp(data["created_at"]) if data["created_at"]
      data["image"] = Pinterest::Image.new(data["image"]) if data["image"]

      new(data)
    end

    # Serialize the object as a Hash that can be serialized as JSON.
    #
    # @param options [Hash] The options to use to serialize.
    # @return [Hash] The serialized object.
    def as_json(options = {})
      super(::Pinterest::User::FIELDS, options)
    end
  end
end
