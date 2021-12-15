# frozen_string_literal: true

require "spec_helper"

RSpec.describe Hyrax::GenericWorksController, type: :request, multitenant: true do
  let(:main_app) { Rails.application.routes.url_helpers }
  let(:user) { create(:user, email: "user@pacificu.edu") }
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
    context "when the work is public" do
      context "when requesting an HTML document" do
        # Make sure normal request still work
        it "returns the correct response" do
          get main_app.polymorphic_path(work)

          expect(response).to be_successful
          expect(response.header.fetch("Content-Type")).to include("text/html")
          expect(response.body).to include(work.title.first)
        end
      end

      context "when requesting a RIS document" do
        it "returns the correct response" do
          get main_app.polymorphic_path(work, format: :ris)

          expect(response).to be_successful
          expect(response.header.fetch("Content-Type")).to include("application/x-research-info-systems")
          expect(response.body).to include("T1  - #{work.title.first}")
        end
      end
    end

    context "when the work is private" do
      let(:work) { create(:work, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE) }

      it "shows a 404" do
        expect { get main_app.polymorphic_path(work, format: :ris) }.to raise_error("ActionController::UnknownFormat")
      end
    end
  end
end
