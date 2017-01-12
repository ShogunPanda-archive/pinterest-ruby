#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Pinterest
  # Base class for entity objects.
  class Entity
    # Parses a timestamps.
    #
    # @param timestamp [String] The string to parse.
    # @return [DateTime] The parsed timestamp.
    def self.parse_timestamp(timestamp)
      return nil if !timestamp || timestamp.empty?
      DateTime.parse(timestamp + "+00:00")
    end

    # Creates a new object.
    #
    # @param data [Hash] The data of the new object.
    # @return [Pinterest::Board] The new object.
    def initialize(data)
      data.each do |field, value|
        send("#{field}=", value) if respond_to?(field)
      end
    end

    # Serialize the object as a Hash that can be serialized as JSON.
    #
    # @param options [Hash] The options to use to serialize.
    # @return [Hash] The serialized object.
    def as_json(fields, options = {})
      fields.reduce({}) do |accu, field|
        value = send(field)
        value = value.as_json(options) if value.respond_to?(:as_json)

        accu[field.to_sym] = value
        accu
      end
    end
  end
end
