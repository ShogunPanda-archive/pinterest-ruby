#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Pinterest
  # A object representing a Pinterest image.
  class Image
    # Creates a new image object.
    #
    # @param data [Hash] The data of the new object.
    # @return [Pinterest::Board] The new board object.
    def initialize(data)
      @data = data
    end

    # Returns the possible versions of a image.
    #
    # @return [Array] A list of possible version of a image.
    def versions
      @data.keys
    end

    # Returns the size of a version of the image.
    #
    # @param version [String] The version to inspect.
    # @return [Hash] A hash with the `:width` and `:height` keys.
    def size(version)
      data = @data.fetch(version.to_s)
      {width: data["width"], height: data["height"]}
    end

    # Returns the URL of a version of the image.
    #
    # @param version [String] The version to inspect.
    # @return [String] The version URL.
    def url(version)
      @data.fetch(version.to_s)["url"]
    end

    # Serialize the object as a Hash that can be serialized as JSON.
    #
    # @param _ [Hash] The options to use to serialize.
    # @return [Hash] The serialized object.
    def as_json(_ = {})
      @data
    end
  end
end
