#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Pinterest::Image do
  subject {
    Pinterest::Image.new({
      "a" => {"width" => 1, "height" => 2, "url" => 3},
      "b" => {"width" => 4, "height" => 5, "url" => 6}
    })
  }

  context "#initialize" do
    it "should save the data" do
      expect(Pinterest::Image.new("DATA").instance_variable_get(:@data)).to eq("DATA")
    end
  end

  context "#versions" do
    it "should return the versions" do
      expect(subject.versions).to eq(["a", "b"])
    end
  end

  context "#size" do
    it "should return the sizes" do
      expect(subject.size("a")).to eq({width: 1, height: 2})
      expect { subject.size("c") }.to raise_error(KeyError)
    end
  end

  context "#url" do
    it "should return the sizes" do
      expect(subject.url("b")).to eq(6)
      expect { subject.url("c") }.to raise_error(KeyError)
    end
  end

  context "#as_json" do
    it "shuold simply return the data" do
      expect(subject.as_json).to eq({
        "a" => {"width" => 1, "height" => 2, "url" => 3},
        "b" => {"width" => 4, "height" => 5, "url" => 6}
      })
    end
  end
end