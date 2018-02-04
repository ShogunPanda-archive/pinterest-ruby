#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Pinterest::Endpoints::Users, vcr: true do
  subject {
    Pinterest::Client.new(access_token: "AVP99QpzwII-f1I2p5gyHi8CiCeQFJkDr8dP-JpDs-LEtAAyegAAAAA")
  }

  context "#me" do
    it "should get the current informations" do
      response = subject.me
      expect(response).to be_a(Pinterest::User)

      expect(response.as_json).to eq({
        id: "559853934835925315",
        username: "shogunpanda",
        first_name: "Paolo",
        last_name: "Insogna",
        bio: "Senior developer in Ruby on Rails, jQuery, HTML5, CSS3, BootStrap, Backbone.JS and others. LARV addicted and nerd on many things. From Molise, Italy.",
        created_at: DateTime.civil(2012, 8, 12, 6, 28, 34),
        counts: {"pins" => 46, "following" => 8, "followers" => 9, "boards" => 2, "likes" => 1},
        image: {
          "60x60" => {"url" => "https://s-media-cache-ak0.pinimg.com/avatars/shogunpanda_1344752914_60.jpg", "width" => 60, "height" => 60
          }
        }
      })
    end

    it "should restrict to requested fields" do
      response = subject.me(fields: ["username", "abc"])
      expect(response.username).to eq("shogunpanda")
      expect(response.first_name).to be_nil
    end
  end

  context "#user" do
    it "should get the current informations" do
      response = subject.user("testerfb11")
      expect(response).to be_a(Pinterest::User)

      expect(response.as_json).to eq({
        id: "332914734862997577",
        username: "testerfb11",
        first_name: "Tester",
        last_name: "tes",
        bio: "",
        created_at: DateTime.civil(2014, 10, 10, 18, 52, 41),
        counts: {"pins" => 1835, "following" => 2, "followers" => 6, "boards" => 18, "likes" => 9},
        image: {
          "60x60" => {"url" => "https://s.pinimg.com/images/user/default_60.png", "width" => 60, "height" => 60
          }
        }
      })
    end

    it "should restrict to requested fields" do
      response = subject.user("testerfb11", fields: ["username", "abc"])
      expect(response.username).to eq("testerfb11")
      expect(response.first_name).to be_nil
    end

    it "should complain for non existent users" do
      expect { subject.user("invalid-user") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end
  end

  context "#followers" do
    it "should return a list of followers" do
      response = subject.followers(limit: 1)

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.next_cursor).to eq("Pz9Nakl5TXpvek16STNOek01T1Rjek56UTJOVEV6TVRRNk9USXlNek0zTWpBek5UUXpNak00T1RneE9GOUZ8NjY4OTYzMGIyMmVhNTVjYjliMzY2NmY1YWVmMWQxODU5MDlhMjk4MjdlYWJmMDc4MTk3NWEzZWM1NWVmMGI4NQ==")
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::User])

      expect(response.records.first.username).to eq("ges_si")
      expect(response.records.first.first_name).to eq("Gessica")
    end

    it "should paginate correctly" do
      response = subject.followers(limit: 1, cursor: "Pz9Nakl5TXpvME9UUTVNRE0xT0RNNU5UazVPREU1TlRrNk9USXlNek0zTURVNE5EZ3hOamcwT0RVeE9WOUZ8ZTQ5MDlkYTI3YTQ1N2Y5NWZiMzQ5YTVjNWI4MjAzZmM5NTBlZWNiNDFiNGI5NmMyMGQyZDdmMzA0MjNhODg1Ng==")
      expect(response.records.first.username).to eq("ges_si")
      expect(response.next?).to be_truthy
    end

    it "should only get requested fields" do
      response = subject.followers(fields: ["username"])
      expect(response.records.first.username).to eq("ges_si")
      expect(response.records.first.first_name).to be_nil
    end
  end

  context "#following_users" do
    it "should return a list of followed users" do
      response = subject.following_users(limit: 2)

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.next_cursor).to eq("Pz9Nakl5TXpvMk9EQTBOamM0TVRjM09ESXpOVFl4TnpvNU1qSXpNemN5TURNMU5EYzJOakUxTWpZNVgwVT18ZmY3MzQyMTMyNWI2ZGVjZTIyODZmZjI2ZGJmMGNjZDEzNWVlZjM2MGRkOWY4ZDQ5YmM2YjdiMzViNTk4MWEyMg==")
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::User])

      expect(response.records.first.username).to eq("rajkadam")
      expect(response.records.first.first_name).to eq("Raj")
    end

    it "should paginate correctly" do
      expect(subject.following_users(limit: 2).size).to eq(2)
      response = subject.following_users(limit: 2, cursor: "Pz9Nakl5TXpvMk9EQTBOamM0TVRjM09ESXpOVFl4TnpvNU1qSXpNemN5TURNMU5EYzJOakUxTWpZNVgwVT18ZmY3MzQyMTMyNWI2ZGVjZTIyODZmZjI2ZGJmMGNjZDEzNWVlZjM2MGRkOWY4ZDQ5YmM2YjdiMzViNTk4MWEyMg==")

      expect(response.records.first.username).to eq("eileenrene11")
      expect(response.size).to eq(2)
      expect(response.next?).to be_truthy
    end

    it "should only get requested fields" do
      response = subject.following_users(fields: ["username"])
      expect(response.records.first.username).to eq("rajkadam")
      expect(response.records.first.first_name).to be_nil
    end
  end

  context "#follow_user" do
    it "should validate the user" do
      expect { subject.follow_user(nil) }.to raise_error(ArgumentError, "You have to specify a user or its id.")
    end

    it "should perform the call and return true" do
      expect(subject.follow_user("testerfb11")).to be_truthy
      expect(subject.follow_user("testerfb11")).to be_truthy
    end

    it "should complain for invalid users" do
      expect { subject.follow_user("invalid-user") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end
  end

  context "#unfollow_user" do
    it "should validate the user" do
      expect { subject.unfollow_user(nil) }.to raise_error(ArgumentError, "You have to specify a user or its id.")
    end

    it "should perform the call and return true" do
      expect(subject.unfollow_user("testerfb11")).to be_truthy
      expect(subject.unfollow_user("testerfb11")).to be_truthy
    end

    it "should complain for invalid users" do
      expect { subject.unfollow_user("invalid-user") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end
  end

  context "#interests" do
    it "should return a list of followed interest" do
      response = subject.interests

      expect(response).to be_a(::Pinterest::Collection)
      expect(response.records.map(&:class).uniq).to eq([::Pinterest::Interest])

      expect(response.records.map(&:name)).to eq(["cats", "puppies", "food"])
    end

    it "should paginate correctly" do
      first_page = subject.interests(limit: 2)
      expect(first_page.size).to eq(2)
      response = subject.interests(limit: 2, cursor: first_page.next_cursor)

      expect(response.records.map(&:name)).to eq(["food"])
      expect(response.size).to eq(1)
      expect(response.next?).to be_falsey
    end
  end

  context "#follow_interest" do
    it "should validate the user" do
      expect { subject.follow_interest(nil) }.to raise_error(ArgumentError, "You have to specify a interest or its id.")
    end

    it "should perform the call and return an error" do
      expect { subject.follow_interest("905661505034") }.to raise_error(::Pinterest::Errors::MethodNotAllowedError)
    end
  end

  context "#unfollow_interest" do
    it "should validate the user" do
      expect { subject.unfollow_interest(nil) }.to raise_error(ArgumentError, "You have to specify a interest or its id.")
    end

    it "should perform the call and return an error" do
      expect { subject.unfollow_interest("905661505034") }.to raise_error(::Pinterest::Errors::NotFoundError)
    end
  end
end