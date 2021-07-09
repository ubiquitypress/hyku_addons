# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::Validations::EntryValidationService, type: :model do
  let(:entry)   { instance_double(HykuAddons::CsvEntry, status: 'Complete', id: 1, identifier: '123') }
  let(:account) { create(:account, name: 'tenant', cname: 'example.com') }

  let(:source_metadata) do
    {
      left_only: true,
      common: true
    }
  end

  let(:destination_metadata) do
    {
      right_only: true,
      common: false
    }
  end

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

    context "with no entry" do
      let(:entry) { nil }

      it "raise an Argument Error" do
        expect { service }.to raise_error(ArgumentError, "You must pass a valid HykuAddons::CsvEntry with  successfully imported items")
      end
    end

    context "with a non complete entry" do
      let(:entry) { instance_double(HykuAddons::CsvEntry, status: 'Pending') }

      it "raise an Argument Error" do
        expect { service }.to raise_error(ArgumentError, "You must pass a valid HykuAddons::CsvEntry with  successfully imported items")
      end
    end
  end

  describe "validate" do
    context 'with no validation errors' do
      before do
        [:left_differences, :right_differences, :merged_fields_differences].each do |validation_method|
          allow(service).to receive(validation_method).and_return([])
        end
      end

      it "returns true" do
        expect(service.validate).to be_truthy
      end

      it "returns no errors" do
        service.validate
        expect(service.errors).to be_empty
      end
    end

    context 'with validation errors' do
      let(:entry) do
        instance_double(HykuAddons::CsvEntry, status: 'Complete', id: 1, current_status: instance_double(Bulkrax::Status, update: true))
      end

      before do
        [:left_differences, :right_differences, :merged_fields_differences].each do |validation_method|
          allow(service).to receive(validation_method).and_return([{ foo: :bar }])
        end
      end

      it "returns false" do
        expect(service.validate).to be_falsey
      end

      it "returns errors" do
        service.validate
        expect(service.errors.count).to eq 3
        expect(service.errors.first).to eq(foo: :bar)
      end

      it 'updates the current status' do
        service.validate
        expect(entry.current_status).to have_received(:update).with(error_backtrace: service.errors)
      end
    end
  end

  describe 'difference matchers' do
    before do
      allow(service).to receive(:source_metadata).and_return(source_metadata)
      allow(service).to receive(:source_metadata_after_transforms).and_return(source_metadata)
      allow(service).to receive(:destination_metadata).and_return(destination_metadata)
      allow(service).to receive(:destination_metadata_after_transforms).and_return(destination_metadata)
    end

    describe 'left' do
      it "returns :remove diffs for items on the left only" do
        expect(service.left_differences).to eq(
          [{ dest_v: nil, op: :remove, path: :left_only, source_v: true, t_dest_v: nil, t_source_v: true }]
        )
      end
    end

    describe 'right' do
      it "returns :add items for the items on the right only" do
        expect(service.right_differences).to eq(
          [{ dest_v: true, op: :add, path: :right_only, source_v: nil, t_dest_v: true, t_source_v: nil }]
        )
      end
    end

    describe 'merged_fields' do
      it "returns :change items for the items appearing on both lists" do
        expect(service.merged_fields_differences).to eq(
          [{ dest_v: false, op: :change, path: :common, source_v: true, t_dest_v: false, t_source_v: true }]
        )
      end

      context 'with non stripped metadata' do
        before do
          source_metadata[:stripped] = " stripped"
          destination_metadata[:stripped] = "stripped "
        end

        it "returns :change items for the items appearing on both lists" do
          expect(service.merged_fields_differences).not_to include(op: :change, path: :stripped, value: 'stripped')
        end
      end
    end
  end

  describe 'source_metadata_after_transforms' do
    before do
      allow(service).to receive(:source_metadata).and_return(data: :something)
      allow(service).to receive(:processable_fields).and_call_original
      allow(service).to receive(:rename_fields).and_call_original
      allow(service).to receive(:reevaluate_fields).and_call_original
    end

    it "delegates the transformation tree" do
      service.source_metadata_after_transforms
      expect(service).to have_received(:processable_fields).with(data: :something)
      expect(service).to have_received(:rename_fields)
      expect(service).to have_received(:reevaluate_fields)
    end
  end

  describe 'destination_metadata_after_transforms' do
    before do
      allow(service).to receive(:destination_metadata).and_return(data: :something)
      allow(service).to receive(:processable_fields).and_call_original
      allow(service).to receive(:rename_fields).and_call_original
      allow(service).to receive(:reevaluate_fields).and_call_original
    end

    it "delegates the transformation tree" do
      service.destination_metadata_after_transforms
      expect(service).to have_received(:processable_fields).with(data: :something)
      expect(service).to have_received(:reevaluate_fields)
      expect(service).not_to have_received(:rename_fields)
    end
  end

  describe 'filter_out_excluded_fields' do
    let(:metadata) do
      {
        foo: :bar,
        bar: :baz,
        empty_string: "",
        empty_string_array: [""],
        exclude: 'true',
        include: 'true'
      }
    end
    let(:excluded_fields) { [:bar] }
    let(:excluded_fields_with_value) { { exclude: 'true', include: 'false' } }
    let(:result) { service.send(:processable_fields, metadata) }

    before do
      allow(described_class).to receive(:excluded_fields).and_return(excluded_fields)
      allow(described_class).to receive(:excluded_fields_with_value).and_return(excluded_fields_with_value)
    end

    it 'removes the excluded fields from the hash param based on EXCLUDED_FIELDS' do
      expect(result.keys).to include(:foo)
      expect(result.keys).not_to include(:bar)
    end

    it 'removes the excluded fields from the hash param based on EXCLUDED_FIELDS_WITH_VALUES' do
      expect(result.keys).not_to include(:exclude)
    end

    it "keeps the fields that don't match the value on EXCLUDED_FIELDS_WITH_VALUES" do
      expect(result.keys).to include(:include)
    end

    it 'removes empty fields and empty strings' do
      expect(result.keys).not_to include(:empty_string)
      expect(result.keys).not_to include(:empty_string_array)
    end
  end

  describe 'rename_fields' do
    let(:metadata) { { foo: :bar, bar: :baz } }
    let(:renamed_fields) { { foo: :fooz, bar: :barz } }

    before do
      allow(described_class).to receive(:renamed_fields).and_return(renamed_fields)
    end

    it 'renames the fields using the RENAMED_FIELDS map' do
      result = service.send(:rename_fields, metadata)
      expect(result).to eq(fooz: :bar, barz: :baz)
    end
  end
end
