# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Active Support Inflectors" do
  let(:options) { { locale: :en, tenant: "Test" } }

  describe "media" do
    it "pluralizes" do
      expect("media".pluralize).to eq "medias"
    end

    it "singgularizes" do
      expect("medias".singularize).to eq "media"
    end
  end
end
