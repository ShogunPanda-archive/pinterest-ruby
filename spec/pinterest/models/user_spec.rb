#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Pinterest::User do
  context ".create" do
    it "should create a object" do
      expect(Pinterest::User.create({})).to be_a(Pinterest::User)
    end

    it "should parse dates" do
      expect(Pinterest::User.create({"created_at" => "2015-11-16T12:34:56+00:00"}).created_at).to eq(DateTime.civil(2015, 11, 16, 12, 34, 56))
    end

    it "should create relationships" do
      expect(Pinterest::Image).to receive(:new).with("IMAGE").and_return("IMAGE-OBJ")

      subject = Pinterest::User.create({"image" => "IMAGE"})
      expect(subject.image).to eq("IMAGE-OBJ")
    end
  end

  context "#as_json" do
    it "should return a hash" do
      expect(Pinterest::Image).to receive(:new).with("IMAGE").and_return("IMAGE-OBJ")

      expect(Pinterest::User.create({
        "id" => "ID", "username" => "USERNAME", "first_name" => "FIRST", "last_name" => "LAST",
        "bio" => "BIO", "created_at" => "2015-11-16T12:34:56+00:00", "counts" => "COUNTS", "image" => "IMAGE"
      }).as_json).to eq({
        id: "ID",
        username: "USERNAME",
        first_name: "FIRST",
        last_name: "LAST",
        bio: "BIO",
        created_at: DateTime.civil(2015, 11, 16, 12, 34, 56),
        counts: "COUNTS",
        image: "IMAGE-OBJ"
      })
    end
  end
end