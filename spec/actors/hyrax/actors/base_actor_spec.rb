# frozen_string_literal: true

RSpec.describe Hyrax::Actors::BaseActor do
  describe "#clean_attributes" do
    subject(:actor) { described_class.new({}) }

    let(:attributes) do
      {
        title: ["1", "2", ""],
        license: "foo",
        rights_statement: "bar",
        "file_set" => ["3", "4", ""] # I hate this too
      }
    end

    it "cleans the attributes" do
      result = actor.send(:clean_attributes, attributes)
      expect(result).to eq(title: ["1", "2"], license: ["foo"], rights_statement: ["bar"])
    end
  end
end
