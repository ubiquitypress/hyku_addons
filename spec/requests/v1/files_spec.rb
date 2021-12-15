# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyku::API::V1::FilesController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:work) { create(:work_with_one_file, visibility: "open") }
  let(:file_set) { work.file_sets.first }

  before do
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) do
      Site.update(account: account)
      work
      if file_set.present?
        file_set.visibility = work.visibility
        file_set.save!
      end
    end
  end

  describe "/tenant/:tenant_id/files/:id/work" do
    it "returns the parent id" do
      get "/api/v1/tenant/#{account.tenant}/files/#{file_set.id}/work"

      expect(response.status).to eq(200)
      expect(response.body).to eq(work.id)
    end
  end
end
