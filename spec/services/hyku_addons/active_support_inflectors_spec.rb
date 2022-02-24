# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveSupport::Inflector do
  describe "media" do
    it "pluralizes" do
      expect("media".pluralize).to eq "medias"
    end

    it "singularizes" do
      expect("medias".singularize).to eq "media"
    end
  end
end
