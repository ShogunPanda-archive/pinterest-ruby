#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Pinterest::Interest do
  context ".create" do
    it "should create a object" do
      expect(Pinterest::Interest.create({})).to be_a(Pinterest::Interest)
    end
  end

  context ".as_json" do
    it "should return a hash" do
      expect(Pinterest::Interest.create({"id" => "ID", "name" => "NAME"}).as_json).to eq({id: "ID", name: "NAME"})
    end
  end
end