# frozen_string_literal: true
require "rails_helper"

RSpec.describe Bolognese::Writers::HykuAddonsWriter do
  describe "#hyku_addons_work" do
    it "responds to the method" do
      expect(Bolognese::Metadata.new).to respond_to(:hyku_addons_work)
    end
  end

  context "Hyku Addons Writer" do
    describe "a complete work" do
      it "outputs correctly" do
        # fixture = File.read Rails.root.join('../fixtures/work_from_doi.xml')
        fixture = File.read Rails.root.join('../fixtures/work_from_doi_complete.xml')

        meta = Bolognese::Metadata.new(input: fixture)

        result = meta.hyku_addons_work(work_model: "generic_work")

        # byebug
        expect(meta.doi).to be_present
        expect(result).to be_a Hash
      end
    end
  end
end
