# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::Validations::SolrEntryValidationService, type: :model do
  let(:entry)   { instance_double(HykuAddons::CsvEntry, status: "Complete", id: 1, identifier: "123") }
  let(:account) { build_stubbed(:account, name: "tenant", cname: "example.com") }

  let(:valid_service_attrs) do
    {
      base_url: "somewhere",
      username: "someone",
      password: "secret"
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

    context "with no source connection info" do
      let(:service) { described_class.new(account, entry, nil, valid_service_attrs) }

      it "raise an Argument Error" do
        expect { service }.to raise_error(ArgumentError, "Source and destination service params must be present")
      end
    end

    context "with no destination connection info" do
      let(:service) { described_class.new(account, entry, valid_service_attrs, nil) }

      it "raise an Argument Error" do
        expect { service }.to raise_error(ArgumentError, "Source and destination service params must be present")
      end
    end
  end

  describe "source_metadata" do
    context "using HTTP Basic Auth" do
      before do
        allow(HykuAddons::BlacklightWorkJsonService).to receive(:new)
          .and_return(instance_double(HykuAddons::BlacklightWorkJsonService, fetch: {}))
      end

      it "uses a BlacklightWorkJsonService" do
        service.source_metadata
        expect(HykuAddons::BlacklightWorkJsonService).to have_received(:new).with(
          valid_service_attrs[:base_url], valid_service_attrs[:username], valid_service_attrs[:password]
        )
      end
    end

    context "using cookies" do
      let(:valid_service_attrs) do
        {
          base_url: "somewhere",
          cookie: "foo"
        }.with_indifferent_access
      end

      before do
        allow(HykuAddons::BlacklightWorkJsonCookieService).to receive(:new)
          .and_return(instance_double(HykuAddons::BlacklightWorkJsonCookieService, fetch: {}))
      end

      it "uses a BlacklightWorkJsonCookieService" do
        service.source_metadata
        expect(HykuAddons::BlacklightWorkJsonCookieService).to have_received(:new)
          .with(valid_service_attrs[:base_url], valid_service_attrs[:cookie])
      end
    end
  end

  describe "reevaluate_fields" do
    let(:reevaluation_result) { service.send(:reevaluate_fields, metadata) }

    describe "reevaluate_creator_tesim" do
      let(:metadata) do
        {
          creator_tesim: [[{
            creator_role: "Role",
            creator_institutional_relationship: "Relationship"
          }].to_json]
        }
      end
      let(:expected_transform) do
        [
          {
            creator_organization_name: "",
            creator_organisation_name: "",
            creator_given_name: "",
            creator_middle_name: "",
            creator_family_name: "",
            creator_name_type: "",
            creator_orcid: "",
            creator_isni: "",
            creator_ror: "",
            creator_grid: "",
            creator_wikidata: "",
            creator_suffix: "",
            creator_role: ["Role"],
            creator_institutional_relationship: ["Relationship"],
            creator_position: "0",
            creator_institution: ""
          }.with_indifferent_access
        ]
      end

      it "makes the reevaluation" do
        expect(JSON.parse(reevaluation_result[:creator_tesim][0])).to eq(expected_transform)
      end
    end

    describe "reevaluate_contributor_tesim" do
      let(:metadata) do
        {
          contributor_tesim: [[{
            contributor_institutional_relationship: "Relationship"
          }].to_json]
        }
      end
      let(:expected_transform) do
        [
          {
            contributor_organization_name: "",
            contributor_organisation_name: "",
            contributor_given_name: "",
            contributor_middle_name: "",
            contributor_family_name: "",
            contributor_name_type: "",
            contributor_orcid: "",
            contributor_isni: "",
            contributor_ror: "",
            contributor_grid: "",
            contributor_wikidata: "",
            contributor_suffix: "",
            contributor_institutional_relationship: ["Relationship"],
            contributor_position: "0",
            contributor_role: [],
            contributor_institution: ""
          }.with_indifferent_access
        ]
      end

      it "makes the reevaluation" do
        expect(JSON.parse(reevaluation_result[:contributor_tesim][0])).to eq(expected_transform)
      end
    end

    describe "date_published_tesim" do
      let(:metadata) { { date_published_tesim: ["2021-01-01"] } }

      it "makes the reevaluation" do
        expect(reevaluation_result).to eq(date_published_tesim: ["2021-1-1"])
      end
    end

    describe "reevaluate_has_model_ssim" do
      let(:metadata) { { has_model_ssim: ["Pacific BookWork Work"] } }

      it "makes the reevaluation" do
        expect(reevaluation_result).to eq(has_model_ssim: ["PacificBook"])
      end
    end

    describe "reevaluate_admin_set_tesim" do
      context "with mappable values" do
        let(:metadata) { { admin_set_tesim: ["Default Admin Set"] } }

        it "makes the reevaluation" do
          expect(reevaluation_result).to eq(admin_set_tesim: ["Default"])
        end
      end

      context "with other admin sets" do
        let(:metadata) { { admin_set_tesim: ["Foo"] } }

        it "changes nothing" do
          expect(reevaluation_result).to eq(admin_set_tesim: ["Foo"])
        end
      end
    end

    describe "reevaluate_human_readable_type_tesim" do
      let(:metadata) { { human_readable_type_tesim: ["Pacific Book Work"] } }

      it "makes the reevaluation" do
        expect(reevaluation_result).to eq(human_readable_type_tesim: ["Pacific Book"])
      end
    end
  end
end
