# frozen_string_literal: true

RSpec.describe Hyrax::Dashboard::WorksSearchBuilder do
  let(:user) { create(:user) }
  let(:ability) { ::Ability.new(user) }
  let(:context) { OpenStruct.new(current_ability: ability, current_user: user, blacklight_config: CatalogController.blacklight_config) }
  let(:builder) { described_class.new(context) }

  describe "search builder .default_processor_chain" do
    it "includes :only_active_works in #default_processor_chain" do
      expect(builder.default_processor_chain).to include(:only_active_works)
    end
  end

  describe "#query method filter include fq parameter which" do
    it "includes suppressed_bsi in the solr query" do
      expect(builder.query["fq"].compact).to include("-suppressed_bsi:true")
    end
  end
end
