# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::Engine do
  describe "Asset Precompile paths" do
    let(:assets) { ["pdf_viewer.css", "pdf_viewer/base.js", "pdf_viewer/locale/*"] }

    it "includes the required types" do
      expect(Rails.application.config.assets.precompile).to include(*assets)
    end
  end
end
