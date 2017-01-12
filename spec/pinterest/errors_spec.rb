#
# This file is part of the pinterest-ruby gem. Copyright (C) 2017 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

require "spec_helper"
require "ostruct"

describe Pinterest::Errors::BaseError do
  context "#initialize" do
    it "should save the code, the reason and the env" do
      subject = Pinterest::Errors::BaseError.new("CODE", "REASON", "ENV")

      expect(subject.message).to eq("[CODE] REASON")
      expect(subject.code).to eq("CODE")
      expect(subject.reason).to eq("REASON")
      expect(subject.env).to eq("ENV")
    end
  end
end

describe Pinterest::Errors do
  context ".create" do
    it "should initialize the right class" do
      subject = Pinterest::Errors.create(OpenStruct.new(status: 401, body: {"error" => "ERROR"}, env: "ENV"))
      expect(subject).to be_a(Pinterest::Errors::AuthorizationError)
      expect(subject.code).to eq(401)
      expect(subject.reason).to eq("ERROR")
      expect(subject.env).to eq("ENV")

      expect(Pinterest::Errors.create(OpenStruct.new(status: 400, body: {"error" => "ERROR"}, env: "ENV"))).to be_a(Pinterest::Errors::BadRequestError)
      expect(Pinterest::Errors.create(OpenStruct.new(status: 403, body: {"error" => "ERROR"}, env: "ENV"))).to be_a(Pinterest::Errors::PermissionsError)
      expect(Pinterest::Errors.create(OpenStruct.new(status: 404, body: {"error" => "ERROR"}, env: "ENV"))).to be_a(Pinterest::Errors::NotFoundError)
      expect(Pinterest::Errors.create(OpenStruct.new(status: 405, body: {"error" => "ERROR"}, env: "ENV"))).to be_a(Pinterest::Errors::MethodNotAllowedError)
      expect(Pinterest::Errors.create(OpenStruct.new(status: 408, body: {"error" => "ERROR"}, env: "ENV"))).to be_a(Pinterest::Errors::TimeoutError)
      expect(Pinterest::Errors.create(OpenStruct.new(status: 429, body: {"error" => "ERROR"}, env: "ENV"))).to be_a(Pinterest::Errors::RateLimitError)
      expect(Pinterest::Errors.create(OpenStruct.new(status: 501, body: {"error" => "ERROR"}, env: "ENV"))).to be_a(Pinterest::Errors::NotImplementedError)

      subject = Pinterest::Errors.create(OpenStruct.new(status: 523, body: {"error" => "ERROR"}, env: "ENV"))
      expect(subject).to be_a(Pinterest::Errors::ServerError)
      expect(subject.code).to eq(523)
    end
  end

  context ".create" do
    it "should return the right class" do
      expect(Pinterest::Errors.class_for_code(400)).to eq(Pinterest::Errors::BadRequestError)
      expect(Pinterest::Errors.class_for_code(401)).to eq(Pinterest::Errors::AuthorizationError)
      expect(Pinterest::Errors.class_for_code(403)).to eq(Pinterest::Errors::PermissionsError)
      expect(Pinterest::Errors.class_for_code(404)).to eq(Pinterest::Errors::NotFoundError)
      expect(Pinterest::Errors.class_for_code(405)).to eq(Pinterest::Errors::MethodNotAllowedError)
      expect(Pinterest::Errors.class_for_code(408)).to eq(Pinterest::Errors::TimeoutError)
      expect(Pinterest::Errors.class_for_code(429)).to eq(Pinterest::Errors::RateLimitError)
      expect(Pinterest::Errors.class_for_code(501)).to eq(Pinterest::Errors::NotImplementedError)
      expect(Pinterest::Errors.class_for_code(503)).to eq(Pinterest::Errors::ServerError)
      expect(Pinterest::Errors.class_for_code(523)).to eq(Pinterest::Errors::ServerError)
    end
  end
end