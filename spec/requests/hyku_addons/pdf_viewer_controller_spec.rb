# frozen_string_literal: true

require "rails_helper"
# TODO: flaky tests. Need fixing.
RSpec.xdescribe "::HykuAddons::PdfViewerController", type: :request, js: true do
  let(:user) { FactoryBot.create(:admin) }
  let!(:account) { create(:account) }

  let!(:work) { create :work_with_one_file, user: user }
  let(:file_set) { work.ordered_members.to_a.first }
  let(:pdf_path) { hyrax.download_url(file_set.id).split("/")&.last&.split("?")&.first }

  before do
    # This feature is accessible to all users, including those not logged in

    Site.update(account: account)
    allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
      block.call
    end
    host! account.cname
    default_url_options[:host] = "http://#{account.cname}"
  end

  after do
    default_url_options.except!(:host)
  end

  describe "GET pdf_viewer" do
    it "loads hypothesis pdf viewer" do
      get hyku_addons.pdf_viewer_path(pdf_path)
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_css("#outerContainer") # outer container of the hypothes.is html
    end
  end
end
