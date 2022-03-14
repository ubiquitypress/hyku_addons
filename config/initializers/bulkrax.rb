# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
::Bulkrax.setup do |config|
  config.export_path = Rails.root.join("tmp", "exports")
  config.system_identifier_field = "source_identifier"
  config.reserved_properties -= ["depositor"]
  config.parsers += [{ class_name: "HykuAddons::CsvParser", name: "Ubiquity Repositiories CSV", partial: "csv_fields" }]

  # NOTE(1): The splits are passed to a Regexp instance, which is passed to split.
  #
  # They must use single quotes with a backslash `'\|'` or double quotes with two backslashes `"\\|"`.
  #
  # Example:
  # value = "funder_award_1_1|funder_award_1_2"
  # value.split(Regexp.new('\|')) # => ["funder_award_1_1", "funder_award_1_2"]
  # value = "funding_description_1_1|funding_description_1_2"
  # value.split(Regexp.new('\|')) # => ["funding_description_1_1", "funding_description_1_2"]
  # value.split(Regexp.new("\|")) # => ["f", "u", "n", "d", "e", "r", "_", ...[REMOVED]... , "_", "1", "_", "2"]
  # value.split(Regexp.new("\\|")) # => ["funder_award_1_1", "funder_award_1_2"]
  # value.split(Regexp.new("\\|")) # => ["funding_description_1_1", "funding_description_1_2"]
  #
  # NOTE(2): Any fields which Bulkrax should not be parsing can be removed by adding the mapping:
  # "field_name" => { excluded: true }
  # The Bulkrax dynamic import will also ignore those fields
  # rubocop:enable Style/StringLiterals
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
    "related_url" => { split: '\|' },
    "collection" => { split: '\|' },
    "place_of_publication" => { split: '\|' },
    "is_format_of" => { split: '\|' },
    "creator_profile_visibility" => { excluded: true }
  }
  # rubocop:enable Style/StringLiterals
end
# rubocop:enable Metrics/BlockLength
