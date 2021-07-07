# frozen_string_literal: true
module HykuAddons
  module Validations
    class RedlandsEntryValidationService < CsvEntryValidationService

      EXCLUDED_FIELDS = %i[
        admin_set calc_url create_openurl csvfile ctmtime depositor document_type id
      ].freeze

      RENAMED_FIELDS = {
        doi_tesim: 'official_link'
      }.with_indifferent_access.freeze

      EXCLUDED_FIELDS_WITH_VALUES = {
        edit_access_group_ssim: ["admin"]
      }.with_indifferent_access.freeze

      SEPARATOR_CHAR = "|"
    end
  end
end
