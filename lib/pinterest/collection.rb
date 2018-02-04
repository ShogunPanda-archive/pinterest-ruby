#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

module Pinterest
  # A collection of objects, including pagination data.
  #
  # @attribute records
  #   @return [Pinterest::Entity] A list of objects.
  # @attribute limit
  #   @return [Fixnum] The maximum number of results to get from Pinterest API.
  # @attribute current_cursor
  #   @return [String] The cursor to obtain the current page of results.
  # @attribute next_cursor
  #   @return [String] The cursor to obtain the next page of results.
  class Collection
    attr_reader :records, :limit, :current_cursor, :next_cursor

    # Creates a new collection. This class is for internal use.
    #
    # @param raw_data [Hash] A raw response obtained by Pinterest API.
    # @param cursor [String] The current cursor.
    # @param limit [Fixnum] The maximum number of records to obtain from Pinterest API.
    # @param record_creator [Proc] The code to trasform each raw record in a object.
    def initialize(raw_data, cursor, limit, &record_creator)
      raise(ArgumentError, "raw_data must be an Hash.") unless raw_data.is_a?(Hash)
      record_creator ||= ->(record) { record }

      @limit = limit
      @current_cursor = cursor
      @next_cursor = raw_data["page"]["cursor"] if raw_data["page"] && raw_data["page"]["cursor"]
      @records = raw_data.fetch("data", []).map(&record_creator)
    end

    # Returns a object from the collection.
    #
    # @param index [Fixnum] The index to get.
    def [](index)
      records[index]
    end

    # Returns the size of the collection.
    #
    # @return [Fixnum] The size of the collection.
    def size
      records.count
    end

    alias_method :count, :size
    alias_method :length, :size

    # Returns the current page cursor.
    #
    # @return [String] The current page cursor.
    def current_page
      current_cursor
    end

    # Returns the next page cursor.
    #
    # @return [String] The next page cursor.
    def next_page
      next_cursor
    end

    # Checks if the collection is empty.
    #
    # @return [Boolean] `true` if the collection is empty, `false` otherwise.
    def empty?
      records.empty?
    end

    # Checks if the collection has a next page.
    #
    # @return [Boolean] `true` if the collection has a next page, `false` otherwise.
    def next?
      !next_cursor.nil?
    end

    alias_method :next_page?, :next?
    alias_method :eof?, :next?

    # Serialize the collection as a Hash that can be serialized as JSON.
    #
    # @param options [Hash] The options to use to serialize.
    # @return [Hash] The serialized collection.
    def as_json(options = {})
      {
        records: records.as_json(options),
        limit: limit,
        current_cursor: current_cursor,
        next_cursor: next_cursor
      }
    end
  end
end
