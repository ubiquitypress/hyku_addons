# frozen_string_literal: true

# This spec is to ensure that configuration removed from the Engine is still being read as it was before the change
RSpec.describe Bulkrax do
  describe ".setup" do
    let(:mappings) do
      {
        "institution" => { split: '\|' },
        "org_unit" => { split: '\|' },
        "fndr_project_ref" => { split: '\|' },
        "project_name" => { split: '\|' },
        "rights_holder" => { split: '\|' },
        "library_of_congress_classification" => { split: '\|' },
        "alt_title" => { split: '\|' },
        "volume" => { split: '\|' },
        "duration" => { split: '\|' },
        "version" => { split: '\|' },
        "publisher" => { split: '\|' },
        "keyword" => { split: '\|' },
        "license" => { split: '\|', parsed: true },
        "subject" => { split: '\|' },
        "language" => { split: '\|' },
        "resource_type" => { split: '\|' },
        "date_published" => { split: '\|', parsed: true },
        "alt_email" => { split: '\|' },
        "isbn" => { split: '\|' },
        "audience" => { split: '\|' },
        "advisor" => { split: '\|' },
        "mesh" => { split: '\|' },
        "subject_text" => { split: '\|' },
        "source" => { split: '\|' },
        "funding_description" => { split: '\|' },
        "citation" => { split: '\|' },
        "references" => { split: '\|' },
        "medium" => { split: '\|' },
        "committee_member" => { split: '\|' },
        "time" => { split: '\|' },
        "add_info" => { split: '\|' },
        "part_of" => { split: '\|' },
        "qualification_subject_text" => { split: '\|' },
        "collection" => { split: '\|' },
        "related_url" => { split: '\|' },
        "creator_profile_visibility" => { excluded: true }
      }
    end

    it "sets the configuration" do
      expect(described_class.export_path.to_s).to eq(Rails.root.join("tmp", "exports").to_s)
      expect(described_class.system_identifier_field).to eq "source_identifier"
      expect(described_class.reserved_properties).not_to include(["depositor"])
      expect(described_class.parsers).to include(
        class_name: "HykuAddons::CsvParser",
        name: "Ubiquity Repositiories CSV",
        partial: "csv_fields"
      )
      expect(described_class.field_mappings["HykuAddons::CsvParser"].sort.to_h).to eq(mappings.sort.to_h)
    end
  end
end
