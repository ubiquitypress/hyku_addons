# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::UpdateAccountFrontendUrl do
  let(:service) { described_class.new(account, frontend_url) }
  let(:account) { create(:account, name: 'tenant') }

  describe "save" do
    let(:frontend_url) { "http://example.com/frontend" }
    before do
      allow(service).to receive(:update_account_frontend_url)
      service.save
    end

    it "updates the frontend_url of the Account" do
      expect(service).to have_received(:update_account_frontend_url)
    end

    context "with an invalid frontend_url" do
      let(:frontend_url) { "" }

      it "updates the frontend_url of the Account" do
        expect(service).not_to have_received(:update_account_frontend_url)
      end
    end
  end

  describe "update_account_frontend_url" do
    let(:frontend_url) { "http://example.com/frontend" }

    before do
      service.save
    end

    it "updates the account frontend_url" do
      expect(account.frontend_url).to eq frontend_url
    end
  end
end
