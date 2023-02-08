# frozen_string_literal: true

require "rails_helper"
# TODO: flaky tests. Need fixing.
RSpec.xdescribe Hyrax::PacificMediasController, type: :controller do
  let!(:work) { PacificMedia.create(title: ["Test"], visibility: "open") }

  describe "responds to" do
    it "responds to html by default" do
      get :show, params: { id: work.id }
      expect(response.content_type).to eq "text/html"
    end

    it "responds to RIS" do
      get :show, params: { id: work.id, format: "ris" }
      expect(response.content_type).to eq "application/x-research-info-systems"
    end
  end
end
