#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Pinterest::Entity do
  class EntityMockClass < Pinterest::Entity
    attr_accessor :a, :b, :c
  end

  context ".parse_timestamp" do
    it "should parse a timestamp" do
      expect(Pinterest::Entity.parse_timestamp("2015-11-16T12:34:56")).to eq(DateTime.civil(2015, 11, 16, 12, 34, 56))
    end
  end

  context "#initialize" do
    it "should initialize valid keys" do
      subject = EntityMockClass.new({a: 1, "b" => 2, d: 4})
      expect(subject.a).to eq(1)
      expect(subject.b).to eq(2)
      expect(subject.c).to be_nil
    end
  end

  context "#as_json" do
    it "should serialize request keys" do
      subject = EntityMockClass.new({a: 1, "b" => 2, d: 4})

      expect(subject.as_json(["a", :c])).to eq({a: 1, c: nil})
    end
  end
end