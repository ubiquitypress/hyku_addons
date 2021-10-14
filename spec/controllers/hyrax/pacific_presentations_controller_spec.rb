# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::PacificPresentationsController, type: :controller do
  let!(:work) { PacificPresentation.create(title: ['Test'], visibility: "open") }

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
