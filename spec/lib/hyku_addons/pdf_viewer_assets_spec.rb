# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PDF Viewer Assets" do
  describe "Asset Precompile" do
    let(:assets) { ["pdf_viewer.css", "pdf_viewer/base.js", "pdf_viewer/locale/*"] }

    it "includes the required types" do
      expect(Rails.application.config.assets.precompile).to include(*assets)
    end
  end
end
