# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::UpdateAccountCname do
  let(:service) { described_class.new(account, cname) }
  let(:account) { create(:account, name: "tenant", cname: "example.com") }

  describe "save" do
    let(:cname) { "foo.example.com" }
    before do
      allow(service).to receive(:update_account_cname)
      service.perform
    end

    it "updates the cname of the Account" do
      expect(service).to have_received(:update_account_cname)
    end

    context "with an invalid cname" do
      let(:cname) { "" }

      it "does not update the cname of the Account" do
        expect(service).not_to have_received(:update_account_cname)
      end
    end
  end

  describe "update_account_cname" do
    let(:cname) { "some.example.com" }
    before do
      service.perform
    end

    it "updates the account cname" do
      expect(account.cname).to eq cname
    end
  end
end
