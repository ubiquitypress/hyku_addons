# frozen_string_literal: true

Bulkrax.setup do |config|
  config.export_path = Rails.root.join("tmp", "exports")
  config.system_identifier_field = "source_identifier"
  config.reserved_properties -= ["depositor"]
  config.parsers += [{ class_name: "HykuAddons::CsvParser", name: "Ubiquity Repositiories CSV", partial: "csv_fields" }]
  #
  # NOTE: The `\|` and "\| produce a different output"
  config.field_mappings["HykuAddons::CsvParser"] = {
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
    "collection" => { split: "\|" }
  }
end
