# frozen_string_literal: true

require "spec_helper"

RSpec.describe Hyrax::GenericWorksController, type: :request, multitenant: true do
  let(:main_app) { Rails.application.routes.url_helpers }
  let(:user) { create(:user) }
  let(:work) { create(:work, user: user) }
  let!(:account) { create(:account) }

	before do
		login_as(user, scope: :user)

    Site.update(account: account)
		allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
			block.call
		end
		host! account.cname
	end

  describe "#show" do
    context "as an RIS file" do
      let(:disposition) { response.header.fetch("Content-Disposition") }
      let(:content_type) { repsonse.header.fetch("Content-Type") }

      it "downloads the file" do

        get "/concern/generic_works/#{work.id}.ris"

        expect(response).to be_successful
#        expect(disposition).to include("attachment")
#        expect(content_type).to eq("application/x-research-info-systems")
#        expect(response.body).to include("T1  - #{work.title}")
      end
    end
  end
end
