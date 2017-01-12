#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"

describe Pinterest::Endpoints::Pins, vcr: true do
  subject {
    Pinterest::Client.new(access_token: "AVP99QpzwII-f1I2p5gyHi8CiCeQFJkDr8dP-JpDs-LEtAAyegAAAAA")
  }

  context "#pin" do
    it "should get the current informations" do
      response = subject.pin("491736853043758927")
      expect(response).to be_a(Pinterest::Pin)

      expect(response.as_json).to eq({
        attribution: nil,
        board: {
          id: "491736921752475493",
          name: "Woodworking",
          url: "https://www.pinterest.com/dderse/woodworking/",
          description: "",
          creator: {
            id: "491736990471948025",
            username: nil,
            first_name: nil,
            last_name: nil,
            bio: nil,
            created_at: nil,
            counts: nil,
            image: nil
          },
          created_at: DateTime.civil(2012, 9, 15, 14, 10, 33),
          counts: {"pins" => 3423, "collaborators" => 0, "followers" => 7618},
          image: {
            "60x60" => {"url" => "https://s-media-cache-ak0.pinimg.com/60x60/8f/a3/01/8fa3011c924838a3afe246419486dde3.jpg", "width" => 60, "height" => 60}
          }
        },
        color: "#ffffff",
        counts: {"likes" => 2, "comments" => 0, "repins" => 12},
        created_at: DateTime.civil(2015, 11, 13, 12, 30, 13),
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
        id: "491736853043758927",
        image: {
          "original" => {"url" => "https://s-media-cache-ak0.pinimg.com/originals/ad/90/47/ad90475f646cb866b31a1dc5c4f754f3.jpg", "width" => 480, "height" => 1056}
        },
        link: "https://www.pinterest.com/r/pin/491736853043758927/4878490596204882047/cea63543062d06243202ee09a1ae786da38078b5c996f5072a58fc89618443a7",
        media: {"type" => "image"},
        note: "Great tip! A really easy way to figure out tricky angles when you're installing moldings, trim, and baseboards.",
        url: "https://www.pinterest.com/pin/491736853043758927/",
      })
    end

    it "should restrict to requested fields" do
      response = subject.pin("491736853043758927", fields: ["color", "abc"])
      expect(response.color).to eq("#ffffff")
      expect(response.link).to be_nil
    end

    it "should complain for non existent pins" do
      expect { subject.pin("invalid-pin") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end
  end

  context "#create_pin" do
    it "should validate the board" do
      expect { subject.create_pin(nil, "http://placehold.it/300x300.png") }.to raise_error(ArgumentError, "You have to specify a board or its id.")
    end

    it "should create a pin by using a image URL" do
      expect(subject.create_pin("shogunpanda/foo-1", "http://placehold.it/300x300.png")).to be_a(Pinterest::Pin)
    end

    it "should create a pin by using a image file" do
      expect(subject.create_pin("shogunpanda/foo-1", __dir__ + "/../fixtures/first.jpg")).to be_a(Pinterest::Pin)
    end

    it "should return a pin containing only requested fields" do
      response = subject.create_pin("shogunpanda/foo-1", "http://placehold.it/300x300.png", note: "NOTE", link: "http://google.it", fields: ["note"])
      expect(response.note).to eq("NOTE")
      expect(response.link).to be_nil
      expect(response.url).to be_nil
    end
  end

  context "#edit_pin" do
    it "should validate the pin" do
      expect { subject.edit_pin(nil) }.to raise_error(ArgumentError, "You have to specify a pin or its id.")
    end

    it "should edit the pin and return it with only the requested fields" do
      response = subject.edit_pin("559853797412741144", note: "Ok", fields: ["note"])
      expect(response.note).to eq("Ok")
      expect(response.link).to be_nil
      expect(response.url).to be_nil
    end
  end

  context "#delete_pin" do
    it "should validate the pin" do
      expect { subject.delete_pin(nil) }.to raise_error(ArgumentError, "You have to specify a pin or its id.")
    end

    it "should perform the call and return true" do
      expect(subject.delete_pin("559853797412741144")).to be_truthy
      expect { subject.delete_pin("559853797412741144") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end

    it "should perform the call and return an error" do
      expect { subject.delete_pin("invalid-pin") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end
  end

  context "#pins" do
    it "should return my pins" do
      response = subject.pins(limit: 2)

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.next_cursor).to eq("LT41NTk4NTM3OTc0MTI3NDExNTc6MnxhYzA2ZDAwYjI4NDhjNTVhMDMxMDU5NWNlODFmOTg5MzIzZmVlNmQ1MDdiZjIxNjY0NDgwYjVkZWZkYjEwNTg3")
      expect(response.size).to eq(2)
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::Pin])

      expect(response.records.first.note).to eq("NOTE")
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/559853797412741158/")
    end

    it "should paginate correctly" do
      response = subject.pins(limit: 50, cursor: "LT41NTk4NTM3OTc0MTI3NDExNTc6MnxhYzA2ZDAwYjI4NDhjNTVhMDMxMDU5NWNlODFmOTg5MzIzZmVlNmQ1MDdiZjIxNjY0NDgwYjVkZWZkYjEwNTg3")
      expect(response.records.first.note).to eq(" ")
      expect(response.size).to eq(47)
    end

    it "should only get requested fields" do
      response = subject.pins(limit: 2, fields: ["url"])

      expect(response.records.first.note).to be_nil
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/559853797412741158/")
    end
  end

  context "#search_my_pins" do
    it "should validate the query" do
      expect { subject.search_my_pins(nil) }.to raise_error(ArgumentError, "You have to specify a query.")
      expect { subject.search_my_pins(" ") }.to raise_error(ArgumentError, "You have to specify a query.")
    end

    it "should search my pins" do
      response = subject.search_my_pins("kitten", limit: 2)

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.next_cursor).to eq("b28yfGNhZGY0ZDM1MjlhNjEwNGYzZTAxYTVjNDlkYjE4MDk2MDczNDMyNTc4ZjYyYmM3Zjg3NWU0ZjA1NDYzYTAyMmE=")
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::Pin])

      expect(response.records.first.note).to eq("Kitten streching")
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/559853797412741184/")
    end

    it "should paginate correctly" do
      response = subject.search_my_pins("kitten", limit: 50, cursor: "b28yfGNhZGY0ZDM1MjlhNjEwNGYzZTAxYTVjNDlkYjE4MDk2MDczNDMyNTc4ZjYyYmM3Zjg3NWU0ZjA1NDYzYTAyMmE=")
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/559853797398871450/")
      expect(response.size).to eq(2)
    end

    it "should only get requested fields" do
      response = subject.search_my_pins("kitten", limit: 50, fields: ["url"])

      expect(response.records.first.note).to be_nil
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/559853797412741184/")
    end
  end

  context "#board_pins" do
    it "should validate the board" do
      expect { subject.board_pins(nil) }.to raise_error(ArgumentError, "You have to specify a board or its id.")
    end

    it "should return the pins of the board" do
      response = subject.board_pins("491736921752475493", limit: 2)

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.next_cursor).to eq("LT40OTE3MzY4NTMwNDk4MzYwNTE6Mnw5ZTRiNmEyOGM5MDMwY2U5MmRkMTNmOWIyMDQyYTIzMjU5NTA2YzAzNTgzY2EwNzlhODBiMzNhOGQwNzg1NTNj")
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::Pin])

      expect(response.records.first.note).to eq("Wooden pallet Shamrock by DoodlesbyDiana on Etsy")
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/491736853049887002/")
    end

    it "should paginate correctly" do
      response = subject.board_pins("491736921752475493", limit: 2, cursor: "LT40OTE3MzY4NTMwNDk4MzYwNTE6Mnw5ZTRiNmEyOGM5MDMwY2U5MmRkMTNmOWIyMDQyYTIzMjU5NTA2YzAzNTgzY2EwNzlhODBiMzNhOGQwNzg1NTNj")
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/491736853049727534/")
    end

    it "should only get requested fields" do
      response = subject.board_pins("491736921752475493", limit: 2, fields: ["url"])

      expect(response.records.first.note).to be_nil
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/491736853049887002/")
    end
  end

  context "#likes" do
    it "should return the list of liked pins" do
      response = subject.likes(limit: 2)

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.next_cursor).to eq("LT41MjcyNzMwNjg4NTkwMDQwMTA6MnxmYWJkMDlhOGI4MmQ3ZTJmNGZhM2ZjMTQ2Y2UwOTdkZTI2ZTA1NmRjYzZhZWQ3NTJlODFhNjBmNThhYzEwNjkw")
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::Pin])

      expect(response.records.first.note).to eq("best-kitten-names-1.jpg (680×411)")
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/414049759476182583/")
    end

    it "should paginate correctly" do
      response = subject.likes(limit: 2, cursor: "LT41MjcyNzMwNjg4NTkwMDQwMTA6MnxmYWJkMDlhOGI4MmQ3ZTJmNGZhM2ZjMTQ2Y2UwOTdkZTI2ZTA1NmRjYzZhZWQ3NTJlODFhNjBmNThhYzEwNjkw")
      expect(response.size).to eq(2)
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/115052965460744443/")
    end

    it "should only get requested fields" do
      response = subject.likes(limit: 1, fields: ["url"])

      expect(response.records.first.note).to be_nil
      expect(response.records.first.url).to eq("https://www.pinterest.com/pin/414049759476182583/")
    end
  end
end