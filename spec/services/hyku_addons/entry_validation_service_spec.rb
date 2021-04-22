# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::EntryValidationService do
  let(:entry)   { instance_double(HykuAddons::CsvEntry, status: 'Complete', id: 1) }
  let(:account) { create(:account, name: 'tenant', cname: 'example.com') }

  let(:valid_service_attrs) do
    {
      base_url: 'somewhere',
      username: 'someone',
      password: 'secret'
    }.with_indifferent_access
  end

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

  let(:service) { described_class.new(account, entry, valid_service_attrs, valid_service_attrs) }

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
      let(:entry) { instance_double(HykuAddons::CsvEntry, status: 'Complete', id: 1, current_status: instance_double(Bulkrax::Status, update: true)) }

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
      allow(service).to receive(:source_metadata_after_transforms).and_return(source_metadata)
      allow(service).to receive(:destination_metadata_after_transforms).and_return(destination_metadata)
    end

    describe 'left_differences' do
      it "returns :remove diffs for items on the left only" do
        expect(service.left_differences).to eq([{ op: :remove, path: :left_only, value: true }])
      end
    end

    describe 'right_differences' do
      it "returns :add items for the items on the right only" do
        expect(service.right_differences).to eq([{ op: :add, path: :right_only, value: true }])
      end
    end

    describe 'merged_fields_differences' do
      it "returns :change items for the items appearing on both lists" do
        expect(service.merged_fields_differences).to eq([{ op: :change, path: :common, value: false }])
      end
    end
  end

  describe "source_metadata" do
    context 'using HTTP Basic Auth' do
      before do
        allow(HykuAddons::BlacklightWorkJsonService).to receive(:new)
          .and_return(instance_double(HykuAddons::BlacklightWorkJsonService, fetch: {}))
      end

      it 'uses a BlacklightWorkJsonService' do
        service.source_metadata
        expect(HykuAddons::BlacklightWorkJsonService).to have_received(:new).with(
          valid_service_attrs[:base_url], valid_service_attrs[:username], valid_service_attrs[:password]
        )
      end
    end

    context 'using cookies' do
      let(:valid_service_attrs) do
        {
          base_url: 'somewhere',
          cookie: 'foo'
        }.with_indifferent_access
      end

      before do
        allow(HykuAddons::BlacklightWorkJsonCookieService).to receive(:new)
          .and_return(instance_double(HykuAddons::BlacklightWorkJsonCookieService, fetch: {}))
      end

      it 'uses a BlacklightWorkJsonCookieService' do
        service.source_metadata
        expect(HykuAddons::BlacklightWorkJsonCookieService).to have_received(:new)
          .with(valid_service_attrs[:base_url], valid_service_attrs[:cookie])
      end
    end
  end

  describe 'source_metadata_after_transforms' do
    before do
      allow(service).to receive(:source_metadata).and_return(data: :something)
      allow(service).to receive(:filter_out_excluded_fields).and_call_original
      allow(service).to receive(:rename_fields).and_call_original
      allow(service).to receive(:reevaluate_fields).and_call_original
    end

    it "delegates the transformation tree" do
      service.source_metadata_after_transforms
      expect(service).to have_received(:filter_out_excluded_fields).with(data: :something)
      expect(service).to have_received(:rename_fields)
      expect(service).to have_received(:reevaluate_fields)
    end
  end

  describe 'destination_metadata_after_transforms' do
    before do
      allow(service).to receive(:destination_metadata).and_return(data: :something)
      allow(service).to receive(:filter_out_excluded_fields).and_call_original
      allow(service).to receive(:rename_fields).and_call_original
      allow(service).to receive(:reevaluate_fields).and_call_original
    end

    it "delegates the transformation tree" do
      service.destination_metadata_after_transforms
      expect(service).to have_received(:filter_out_excluded_fields).with(data: :something)
      expect(service).to have_received(:reevaluate_fields)
      expect(service).not_to have_received(:rename_fields)
    end
  end

  describe 'filter_out_excluded_fields' do
    let(:metadata) { { foo: :bar, bar: :baz } }
    let(:excluded_fields) { [:bar] }

    before do
      stub_const("HykuAddons::EntryValidationService::EXCLUDED_FIELDS", excluded_fields)
    end

    it 'removes the excluded fields from the hash param' do
      result = service.send(:filter_out_excluded_fields, metadata)
      expect(result.keys).to include(:foo)
      expect(result.keys).not_to include(:bar)
    end
  end

  describe 'rename_fields' do
    let(:metadata) { { foo: :bar, bar: :baz } }
    let(:renamed_fields) { { foo: :fooz, bar: :barz } }

    before do
      stub_const("HykuAddons::EntryValidationService::RENAMED_FIELDS", renamed_fields)
    end

    it 'renames the fields using the RENAMED_FIELDS map' do
      result = service.send(:rename_fields, metadata)
      expect(result).to eq(fooz: :bar, barz: :baz)
    end
  end

  describe 'reevaluate_fields' do
    let(:reevaluation_result) { service.send(:reevaluate_fields, metadata) }

    describe 'reevaluate_creator_tesim' do
      let(:metadata) do
        {
          creator_tesim: [[{
            creator_role: 'Role',
            creator_institutional_relationship: 'Relationship'
          }].to_json]
        }
      end

      it "makes the reevaluation" do
        expect(JSON.parse(reevaluation_result[:creator_tesim][0])).to eq(
          [
            {
              creator_organization_name: '',
              creator_given_name: '',
              creator_middle_name: '',
              creator_family_name: '',
              creator_name_type: '',
              creator_orcid: '',
              creator_isni: '',
              creator_ror: '',
              creator_grid: '',
              creator_wikidata: '',
              creator_suffix: '',
              creator_role: ['Role'],
              creator_institutional_relationship: ['Relationship'],
              creator_position: '0',
              creator_institution: ''
            }.with_indifferent_access
          ]
        )
      end
    end

    describe 'reevaluate_contributor_tesim' do
      let(:metadata) do
        {
          contributor_tesim: [[{
            contributor_institutional_relationship: 'Relationship'
          }].to_json]
        }
      end

      it "makes the reevaluation" do
        expect(JSON.parse(reevaluation_result[:contributor_tesim][0])).to eq(
          [
            {
              contributor_organization_name: '',
              contributor_given_name: '',
              contributor_middle_name: '',
              contributor_family_name: '',
              contributor_name_type: '',
              contributor_orcid: '',
              contributor_isni: '',
              contributor_ror: '',
              contributor_grid: '',
              contributor_wikidata: '',
              contributor_suffix: '',
              contributor_institutional_relationship: ['Relationship'],
              contributor_position: '0',
              contributor_institution: ''
            }.with_indifferent_access
          ]
        )
      end
    end

    describe 'date_published_tesim' do
      let(:metadata) { { date_published_tesim: ['2021-01-01'] } }

      it "makes the reevaluation" do
        expect(reevaluation_result).to eq(date_published_tesim: ['2021-1-1'])
      end
    end

    describe 'reevaluate_has_model_ssim' do
      let(:metadata) { { has_model_ssim: ['Pacific BookWork Work'] } }

      it "makes the reevaluation" do
        expect(reevaluation_result).to eq(has_model_ssim: ['PacificBook'])
      end
    end

    describe 'reevaluate_human_readable_type_tesim' do
      let(:metadata) { { human_readable_type_tesim: ['Pacific Book Work'] } }

      it "makes the reevaluation" do
        expect(reevaluation_result).to eq(human_readable_type_tesim: ['Pacific Book'])
      end
    end
  end
end
