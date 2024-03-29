# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::Validations::RedlandsEntryValidationService, type: :model do
  let(:entry)   { instance_double(HykuAddons::CsvEntry, status: "Complete", id: 1, identifier: "123") }
  let(:account) { build_stubbed(:account, name: "tenant", cname: "example.com") }

  let(:service) { described_class.new(account, entry) }

  describe "initialize" do
    context "with valid params" do
      it "returns an instance" do
        expect(service).to be_a(described_class)
      end
    end

    context "with no account" do
      let(:account) { nil }

      it "raise an Argument Error" do
        expect { service }.to raise_error(ArgumentError, "You must pass a valid Account")
      end
    end
  end

  describe "filter_out_excluded_fields" do
    let(:metadata) do
      described_class.excluded_fields
                     .each_with_object("")
                     .to_h.merge(foo: :bar)
    end
    let(:excluded_fields_with_values) { { exclude: "true", include: "false" } }
    let(:result) { service.send(:processable_fields, metadata) }

    it "keeps attrs not listed" do
      expect(result.keys).to include(:foo)
    end

    described_class.excluded_fields.each do |field|
      it "removes #{field} from the list based on EXCLUDED_FIELDS" do
        expect(result.keys).not_to include(:bar)
      end
    end
  end
end
