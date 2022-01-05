# frozen_string_literal: true
require "rails_helper"

RSpec.describe Hyku::API::V1::UsersController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:public_user) { create(:user, display_profile: true) }
  let(:public_user_2) { create(:user, display_profile: true) }
  let(:private_user) { create(:user) }

  before do
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) do
      Site.update(account: account)
      public_user
      public_user_2
      private_user
    end
  end

  describe "/users" do
    let(:json_response) { JSON.parse(response.body) }
    it "Only displays users that allow public display" do
      get "/api/v1/tenant/#{account.tenant}/users"
      expect(json_response["total"]).to eq(2)
      expect(json_response["items"]).to include(a_hash_including("id" => public_user.id))
      expect(json_response["items"]).to include(a_hash_including("id" => public_user_2.id))
    end
  end

  describe "/users/:email" do
    let(:json_response) { JSON.parse(response.body) }

    context "When user does not want to be publically avalible" do
      it "Does not display user json" do
        get "/api/v1/tenant/#{account.tenant}/users/#{private_user.email}"
        expect(json_response).to include("message" => "This User is either private or does not exist")
      end
    end

    context "When user allows public display of profile" do
      it "Displays user JSON" do
        get "/api/v1/tenant/#{account.tenant}/users/#{public_user.email}"
        expect(response.status).to eq(200)
        expect(json_response).to include("email" => public_user.email.to_s,
                                         "id" => public_user.id,
                                         "display_name" => nil,
                                         "facebook_handle" => nil,
                                         "twitter_handle" => nil,
                                         "googleplus_handle" => nil,
                                         "linkedin_handle" => nil,
                                         "orcid" => nil,
                                         "address" => nil,
                                         "department" => nil,
                                         "title" => nil,
                                         "office" => nil,
                                         "chat_id" => nil,
                                         "website" => nil,
                                         "affiliation" => nil,
                                         "telephone" => nil,
                                         "avatar_file_name" => nil,
                                         "avatar_content_type" => nil,
                                         "avatar_file_size" => nil,
                                         "avatar_updated_at" => nil,
                                         "biography" => nil,
                                         "works" => [])
      end
    end
  end
end
