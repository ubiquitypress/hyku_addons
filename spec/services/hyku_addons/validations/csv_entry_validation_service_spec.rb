# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::Validations::CsvEntryValidationService, type: :model do
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
end
