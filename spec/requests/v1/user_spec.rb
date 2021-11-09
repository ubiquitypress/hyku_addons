# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyku::API::V1::UserController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:user) { create(:user) }

  before do
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) do
      Site.update(account: account)
      user
    end
  end

  describe "/user/:id" do
    let(:json_response) { JSON.parse(response.body) }

    context "When user does not want to be publically avalible" do
      it "Does not display user json" do
        get "/api/v1/tenant/#{account.tenant}/user/#{user.email}"
        expect(json_response).to include('message' => "This User is private")
      end
    end

    context "When user allows public display of profile" do
      it "Displays user JSON" do
        user.display_profile = true
        user.save!
        get "/api/v1/tenant/#{account.tenant}/user/#{user.email}"
        expect(response.status).to eq(200)
        expect(json_response).to include(
                                       "email"=>"#{user.email}",
                                       "display_name"=>nil,
                                       "facebook_handle"=>nil,
                                       "twitter_handle"=>nil,
                                       "googleplus_handle"=>nil,
                                       "linkedin_handle"=>nil,
                                       "orcid"=>nil,
                                       "address"=>nil,
                                       "department"=>nil,
                                       "title"=>nil, "office"=>nil,
                                       "chat_id"=>nil,
                                       "website"=>nil,
                                       "affiliation"=>nil,
                                       "telephone"=>nil,
                                       "avatar_file_name"=>nil,
                                       "avatar_content_type"=>nil,
                                       "avatar_file_size"=>nil,
                                       "avatar_updated_at"=>nil)
      end
    end
  end
end
