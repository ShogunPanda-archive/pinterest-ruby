#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Pinterest::Endpoints::Boards, vcr: true do
  subject {
    Pinterest::Client.new(access_token: "AVP99QpzwII-f1I2p5gyHi8CiCeQFJkDr8dP-JpDs-LEtAAyegAAAAA")
  }

  context "#board" do
    it "should get the current informations" do
      response = subject.board("491736921752475493")
      expect(response).to be_a(Pinterest::Board)

      expect(response.as_json).to eq({
        counts: {"pins" => 3423, "collaborators" => 0, "followers" => 7618},
        created_at: DateTime.civil(2012, 9, 15, 14, 10, 33),
        creator: {
          id: "491736990471948025",
          username: "dderse",
          first_name: "Daniel",
          last_name: "Derse",
          bio: "",
          created_at: DateTime.civil(2012, 9, 3, 13, 21, 48),
          counts: {"pins" => 23400, "following" => 691, "followers" => 13079, "boards" => 37, "likes" => 35},
          image: {
            "60x60" => {"url" => "https://s-media-cache-ak0.pinimg.com/avatars/dderse_1477012877_60.jpg", "width" => 60, "height" => 60}
          }
        },
        description: "",
        id: "491736921752475493",
        image: {
          "60x60" => {"url" => "https://s-media-cache-ak0.pinimg.com/60x60/8f/a3/01/8fa3011c924838a3afe246419486dde3.jpg", "width" => 60, "height" => 60}
        },
        name: "Woodworking",
        url: "https://www.pinterest.com/dderse/woodworking/"
      })
    end

    it "should restrict to requested fields" do
      response = subject.board("491736921752475493", fields: ["abc", "url"])
      expect(response.url).to eq("https://www.pinterest.com/dderse/woodworking/")
      expect(response.name).to be_nil
    end

    it "should complain for invalid boards" do
      expect { subject.board("invalid-board") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end
  end

  context "#boards" do
    it "should return a list of boards" do
      response = subject.boards

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::Board])

      expect(response.records.first.name).to eq("9GAG")
      expect(response.records.first.url).to eq("https://www.pinterest.com/shogunpanda/9gag/")
    end

    it "should only get requested fields" do
      response = subject.boards(fields: ["name"])
      expect(response.records.first.name).to eq("9GAG")
      expect(response.records.first.url).to be_nil
    end
  end

  context "#create_board" do
    it "should complain when the name is missing" do
      expect { subject.create_board("") }.to raise_error(ArgumentError, "You have to specify the board name.")
    end

    it "should create the board and return it with only the requested fields" do
      response = subject.create_board("Foo", "Bar", fields: ["name"])
      expect(response).to be_a(Pinterest::Board)
      expect(response.name).to eq("Foo")
      expect(response.creator).to be_nil
    end
  end

  context "#edit_board" do
    it "should validate the board" do
      expect { subject.edit_board(nil, name: "") }.to raise_error(ArgumentError, "You have to specify a board or its id.")
    end

    it "should edit the board and return it with only the requested fields" do
      response = subject.edit_board("559853866116962371", description: "Baz", fields: ["description"])
      expect(response).to be_a(Pinterest::Board)
      expect(response.description).to eq("Baz")
      expect(response.creator).to be_nil
    end
  end

  context "#delete_board" do
    it "should validate the board" do
      expect { subject.delete_board(nil) }.to raise_error(ArgumentError, "You have to specify a board or its id.")
    end

    it "should perform the call and return true" do
      expect(subject.delete_board("559853866116962371")).to be_truthy
      expect { subject.board("559853866116962371") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end

    it "should perform the call and return an error" do
      expect { subject.delete_board("invalid-board") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end
  end

  context "#search_my_boards" do
    it "should validate the query" do
      expect { subject.search_my_boards(nil) }.to raise_error(ArgumentError, "You have to specify a query.")
      expect { subject.search_my_boards(" ") }.to raise_error(ArgumentError, "You have to specify a query.")
    end

    it "should search boards" do
      response = subject.search_my_boards("foo", limit: 2)

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.next_cursor).to eq("b28yfGNhZGY0ZDM1MjlhNjEwNGYzZTAxYTVjNDlkYjE4MDk2MDczNDMyNTc4ZjYyYmM3Zjg3NWU0ZjA1NDYzYTAyMmE=")
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::Board])

      expect(response.records.first.name).to eq("Foo 3")
      expect(response.records.first.url).to eq("https://www.pinterest.com/shogunpanda/foo-3/")
    end

    it "should paginate correctly" do
      response = subject.search_my_boards("foo", limit: 2, cursor: "b28yfGNhZGY0ZDM1MjlhNjEwNGYzZTAxYTVjNDlkYjE4MDk2MDczNDMyNTc4ZjYyYmM3Zjg3NWU0ZjA1NDYzYTAyMmE=")
      expect(response.records.first.name).to eq("Foo 1")
      expect(response.size).to eq(1)
    end

    it "should only get requested fields" do
      response = subject.search_my_boards("foo", limit: 2, fields: ["url"])

      expect(response.records.first.name).to be_nil
      expect(response.records.first.url).to eq("https://www.pinterest.com/shogunpanda/foo-3/")
    end
  end

  context "#suggested_boards" do
    it "should return the suggested boards returning only the requested fields" do
      response = subject.suggested_boards(limit: 2, fields: ["url"])

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::Board])
      expect(response.records.first.name).to be_nil
      expect(response.records.first.url).to eq("https://www.pinterest.com/shogunpanda/foo-3/")
    end
  end

  context "#following_boards" do
    it "should return the followed boards" do
      response = subject.following_boards(limit: 2)

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.next_cursor).to eq("Pz9Nakl5TlRvNE5UazVNRGMwTWpneU5ESXhPVEF5TnpvNU1qSXpNemN3TlRVeU5qTXhNRE16TnpZenw0ZjEwYWZkYWRlOGI2MjMzMzk1ZGJiYjllYjBmMWY3NzVjNTg4OTc3ODRlNWJjZTdlMTliN2UyYzQ5Njc4MWY5")
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::Board])

      expect(response.records.first.name).to eq("Drinks")
      expect(response.records.first.url).to eq("https://www.pinterest.com/gemmorgan/drinks/")
    end

    it "should paginate correctly" do
      response = subject.following_boards(limit: 2, cursor: "Pz9Nakl5TlRvNE5UazVNRGMwTWpneU5ESXhPVEF5TnpvNU1qSXpNemN3TlRVeU5qTXhNRE16TnpZenw0ZjEwYWZkYWRlOGI2MjMzMzk1ZGJiYjllYjBmMWY3NzVjNTg4OTc3ODRlNWJjZTdlMTliN2UyYzQ5Njc4MWY5")
      expect(response.records.first.name).to eq("Tigers")
    end

    it "should only get requested fields" do
      response = subject.following_boards(limit: 2, fields: ["url"])

      expect(response.records.first.name).to be_nil
      expect(response.records.first.url).to eq("https://www.pinterest.com/gemmorgan/drinks/")
    end
  end

  context "#follow_board" do
    it "should validate the board" do
      expect { subject.follow_board(nil) }.to raise_error(ArgumentError, "You have to specify a board or its id.")
    end

    it "should perform the call and return true" do
      expect(subject.follow_board("491736921752475493")).to be_truthy
      expect(subject.follow_board("491736921752475493")).to be_truthy
    end

    it "should complain for invalid boards" do
      expect { subject.follow_board("invalid-board") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end
  end

  context "#unfollow_board" do
    it "should validate the board" do
      expect { subject.unfollow_board(nil) }.to raise_error(ArgumentError, "You have to specify a board or its id.")
    end

    it "should perform the call and return true" do
      expect(subject.unfollow_board("491736921752475493")).to be_truthy
      expect(subject.unfollow_board("491736921752475493")).to be_truthy
    end

    it "should complain for invalid boards" do
      expect { subject.follow_board("invalid-board") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end
  end
end