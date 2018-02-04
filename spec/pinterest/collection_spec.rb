#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Pinterest::Collection do
  context "#initialize" do
    it "should save limit and cursor" do
      subject = Pinterest::Collection.new({}, "CURSOR", "LIMIT")
      expect(subject.current_cursor).to eq("CURSOR")
      expect(subject.limit).to eq("LIMIT")
    end

    it "should save the next_cursor" do
      expect(Pinterest::Collection.new({}, "CURSOR", "LIMIT").next_cursor).to be_nil
      expect(Pinterest::Collection.new({"page" => {"cursor" => "NEXT"}}, "CURSOR", "LIMIT").next_cursor).to eq("NEXT")
    end

    it "should save the records by applying the creator" do
      subject = Pinterest::Collection.new({"data" => ["12", "34", "56"]}, "CURSOR", "LIMIT") { |r| r.reverse }
      expect(subject.records).to eq(["21", "43", "65"])
    end

    it "should complain if invalid raw_data is passed" do
      expect { Pinterest::Collection.new(nil, nil, nil) }.to raise_error(ArgumentError)
    end
  end

  context "[]" do
    it "should act as an array" do
      expect(Pinterest::Collection.new({"data" => ["12", "34", "56"]}, "CURSOR", "LIMIT")[1]).to eq("34")
    end
  end

  context "#size" do
    it "should act as an array" do
      expect(Pinterest::Collection.new({"data" => ["12", "34", "56"]}, "CURSOR", "LIMIT").size).to eq(3)
    end
  end

  context "#current_page" do
    it "should return the current cursor" do
      expect(Pinterest::Collection.new({"data" => ["12", "34", "56"]}, "CURSOR", "LIMIT").current_page).to eq("CURSOR")
    end
  end

  context "#next_page" do
    it "should return the current cursor" do
      expect(Pinterest::Collection.new({"page" => {"cursor" => "NEXT"}}, "CURSOR", "LIMIT").next_page).to eq("NEXT")
    end
  end

  context "#empty?" do
    it "should return whether the collection is empty" do
      expect(Pinterest::Collection.new({"data" => ["12", "34", "56"]}, "CURSOR", "LIMIT").empty?).to be_falsey
      expect(Pinterest::Collection.new({}, "CURSOR", "LIMIT").empty?).to be_truthy
    end
  end

  context "#next?" do
    it "should return whether the collection has more data on the server" do
      expect(Pinterest::Collection.new({}, "CURSOR", "LIMIT").next?).to be_falsey
      expect(Pinterest::Collection.new({"page" => {"cursor" => "NEXT"}}, "CURSOR", "LIMIT").next_cursor).to be_truthy
    end
  end

  context "#as_json" do
    it "should serialize the collection" do
      subject = Pinterest::Collection.new({"data" => ["12", "34", "56"], "page" => {"cursor" => "NEXT"}}, "CURSOR", "LIMIT")
      allow_any_instance_of(Array).to receive(:as_json){ |obj| obj }

      expect(subject.as_json).to eq({
        records: ["12", "34", "56"],
        limit: "LIMIT",
        current_cursor: "CURSOR",
        next_cursor: "NEXT"
      })
    end
  end
end