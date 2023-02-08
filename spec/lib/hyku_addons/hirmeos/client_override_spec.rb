# frozen_string_literal: true
require "jwt"
require "rails_helper"
# TODO: flaky tests. Need fixing.
RSpec.xdescribe HykuAddons::Hirmeos::ClientOverride do
  subject(:client) do
    Hyrax::Hirmeos::Client.new(username: "UsernameTest",
                               password: "Password",
                               secret: "myt$stkey",
                               translation_base_url: "https://translator.example.com",
                               token_base_url: "https://tokens.example.com")
  end
  let(:work) { create(:work) }

  before do
    stub_request(:any, "https://translator.example.com/works")
  end

  describe "#generate_token" do
    it "generates a token for authentication" do
      sample_payload = {
        "app": "hyku",
        "purpose": "test"
      }
      token = client.generate_token(sample_payload)
      expect(token).to be_present
      decoded_token = JWT.decode token, client.instance_variable_get(:@secret)
      expect(decoded_token).to include(hash_including("app" => "hyku", "purpose" => "test"))
    end
  end

  it "takes a default payload structure" do
    token = client.generate_token
    decoded_token = JWT.decode token, client.instance_variable_get(:@secret)
    expect(decoded_token).to include(hash_including("iat" => a_kind_of(Integer), "exp" => a_kind_of(Integer)))
  end

  it "Does not make a call to the tokens API when submitting a resource" do
    client.post_resource(work)
    expect(a_request(:post, "https://translator.example.com/works")).to have_been_made.at_least_once
    expect(a_request(:post, "https://tokens.example.com")).not_to have_been_made
  end
end
