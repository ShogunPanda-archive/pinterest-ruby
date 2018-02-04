#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Pinterest
  # A object representing a Pinterest interest (topic).
  class Interest < Entity
    # The list of fields of the object.
    FIELDS = ["id", "name"].freeze

    attr_accessor(*FIELDS)

    # Creates a new interest (topic) object.
    #
    # @param data [Hash] The data of the new object. For a list of valid fields, see `Pinterest::Interest::FIELDS`.
    # @return [Pinterest::Board] The new interest object.
    def self.create(data)
      new(data)
    end

    # Serialize the object as a Hash that can be serialized as JSON.
    #
    # @param options [Hash] The options to use to serialize.
    # @return [Hash] The serialized object.
    def as_json(options = {})
      super(::Pinterest::Interest::FIELDS, options)
    end
  end
end
