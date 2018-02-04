#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Pinterest::Endpoints::Authentication, vcr: true do
  subject {
    Pinterest::Client.new(client_id: $pinterest_client_id, client_secret: $pinterest_client_secret)
  }

  context "#authorization_state" do
    it "should return a string" do
      expect(subject.authorization_state).to match(/^[a-f0-9]+$/)
    end
  end

  context "#authorization_url" do
    before(:each) do
      allow(subject).to receive(:authorization_state).and_return("STATE")
    end

    it "should complain when mandatory arguments are missing" do
      expect { Pinterest::Client.new.authorization_url }.to raise_error(ArgumentError, "You must specify the client_id.")
      expect { subject.authorization_url }.to raise_error(ArgumentError, "You must specify the callback_url.")
      expect { subject.authorization_url(1) }.to raise_error(ArgumentError, "callback_url must be a valid HTTPS URL.")
      expect { subject.authorization_url("ABC") }.to raise_error(ArgumentError, "callback_url must be a valid HTTPS URL.")
      expect { subject.authorization_url("http://google.it") }.to raise_error(ArgumentError, "callback_url must be a valid HTTPS URL.")
    end

    it "should return a valid URL requesting all scopes" do
      expect(subject.authorization_url("https://localhost")).to eq(
        "https://api.pinterest.com/oauth?authorization_state=STATE&client_id=#{$pinterest_client_id}&redirect_uri=https%3A%2F%2Flocalhost&response_type=code&scope=read_public%2Cwrite_public%2Cread_relationships%2Cwrite_relationships"
      )
    end

    it "should return a valid URL requesting specified scopes and removing invalid ones" do
      expect(subject.authorization_url("https://localhost", ["a", "read_public"])).to eq(
        "https://api.pinterest.com/oauth?authorization_state=STATE&client_id=#{$pinterest_client_id}&redirect_uri=https%3A%2F%2Flocalhost&response_type=code&scope=read_public"
      )
    end
  end

  context "#fetch_access_token" do
    it "should complain when mandatory arguments are missing" do
      expect { Pinterest::Client.new.fetch_access_token("A") }.to raise_error(ArgumentError, "You must specify the client_id.")
      expect { Pinterest::Client.new(client_id: $pinterest_client_id).fetch_access_token("A") }.to raise_error(ArgumentError, "You must specify the client_secret.")
      expect { subject.fetch_access_token(nil) }.to raise_error(ArgumentError, "You must specify the authorization_token.")
    end

    it "should make the call to Pinterest and return the authorization token, also saving it" do
      expect(subject.access_token).to be_nil
      expect(subject.fetch_access_token("9568cec6cc78aa05")).to eq("AVP99QpzwII-f1I2p5gyHi8CiCeQFJkDr8dP-JpDs-LEtAAyegAAAAA")
      expect(subject.access_token).to eq("AVP99QpzwII-f1I2p5gyHi8CiCeQFJkDr8dP-JpDs-LEtAAyegAAAAA")
    end
  end

  context "#verify_access_token" do
    it "should verify the token" do
      subject.access_token = "AVP99QpzwII-f1I2p5gyHi8CiCeQFJkDr8dP-JpDs-LEtAAyegAAAAA"

      expect(subject.verify_access_token).to eq({
        application_id: $pinterest_client_id,
        created_at: DateTime.civil(2017, 01, 12, 11, 44, 40),
        scopes: ["read_public", "write_public", "read_relationships", "write_relationships"],
        user_id: "559853934835925315"
      })
    end

    it "should complain when no access token is set" do
      expect { Pinterest::Client.new.fetch_access_token("A") }.to raise_error(ArgumentError, "You must specify the client_id.")
      expect { subject.verify_access_token }.to raise_error(ArgumentError, "You must set the access token first.")
    end

    it "should return an exception when using an invalid token" do
      subject.access_token = "A"
      expect { subject.verify_access_token }.to raise_error(Pinterest::Errors::AuthorizationError)
    end
  end
end