#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Pinterest::Client, vcr: true do
  context "#initialize" do
    it "should save the attributes and run the default block to setup the connection" do
      expect_any_instance_of(Pinterest::Client).to receive(:default_connection_setup).and_call_original
      subject = Pinterest::Client.new(access_token: "A", client_id: "B", client_secret: "C", verbose: "D")

      expect(subject.access_token).to eq("A")
      expect(subject.client_id).to eq("B")
      expect(subject.client_secret).to eq("C")
      expect(subject.verbose).to eq("D")
      expect(subject.connection).to be_a(Faraday::Connection)
      expect(subject.connection.url_prefix.to_s).to eq(::Pinterest::Client::API_URL + "/")
    end

    it "should run the default block" do
      a = 1

      Pinterest::Client.new(access_token: "A", client_id: "B", client_secret: "C", verbose: "D") do
        a = 2
      end

      expect(a).to eq(2)
    end
  end

  context "#ensure_array (private)" do
    it "should return an array" do
      subject = Pinterest::Client.new
      expect(subject.send(:ensure_array, [])).to eq([])
      expect(subject.send(:ensure_array, "a")).to eq(["a"])
      expect(subject.send(:ensure_array, nil, "b")).to eq(["b"])
    end
  end

  context "#ensure_param (private)" do
    it "should check if parameter is present" do
      subject = Pinterest::Client.new
      expect(subject.send(:ensure_param, "a")).to be_truthy
      expect(subject.send(:ensure_param, "")).to be_falsey
      expect(subject.send(:ensure_param, " ")).to be_falsey
      expect(subject.send(:ensure_param, nil)).to be_falsey
      expect { subject.send(:ensure_param, "", "MESSAGE") }.to raise_error(ArgumentError, "MESSAGE")
    end
  end

  context "#cleanup_params (private)" do
    it "should remove keys which are not set" do
      expect(Pinterest::Client.new.send(:cleanup_params, {a: 1, b: 2, c: nil, d: ""})).to eq({a: 1, b: 2})
    end
  end

  context "#perform_network_request (private)" do
    it "should correctly handle malformed requests" do
      expect { subject.send(:perform_network_request, url: "/foo") }.to raise_error(Pinterest::Errors::NotFoundError, "[404] Invalid response from the server.")
    end
  end

  context "#versioned_url (private)" do
    it "should prepend version path to a URL" do
      expect(Pinterest::Client.new.send(:versioned_url, "abc")).to eq("/v1/abc")
    end
  end
end