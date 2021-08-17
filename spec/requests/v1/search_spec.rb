# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyku::API::V1::SearchController, type: :request, clean: true, multitenant: true do
  let(:account) { FactoryBot.create(:account, locale_name: 'anschutz') }
  let(:user) { create(:user) }
  let(:work) { nil }
  let(:collection) { nil }

  before do
    WebMock.disable!
    Apartment::Tenant.create(account.tenant)
    Apartment::Tenant.switch(account.tenant) do
      Site.update(account: account)
      user
      work
      collection
    end
  end

  after do
    WebMock.enable!
    Apartment::Tenant.drop(account.tenant)
  end

  describe "/search/facet/:id" do
    let(:json_response) { JSON.parse(response.body) }

    context 'all facets' do
      let(:work) { create(:work, visibility: 'open', keyword: ['test2'], language: ['eng']) }
      let(:another_work) { create(:work, visibility: 'open', keyword: ['test', 'test2'], language: ['zho']) }
      let(:id) { 'all' }

      before do
        Apartment::Tenant.switch(account.tenant) { another_work }
      end

      it "returns the result ordered by hits" do
        get "/api/v1/tenant/#{account.tenant}/search/facet/#{id}"
        expect(response.status).to eq(200)
        expect(json_response['keyword_sim'].to_a).to eq({ "test2" => 2, "test" => 1 }.to_a)
      end
    end
  end
end
