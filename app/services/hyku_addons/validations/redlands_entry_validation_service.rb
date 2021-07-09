# frozen_string_literal: true
module HykuAddons
  module Validations
    class RedlandsEntryValidationService < CsvEntryValidationService
      @excluded_fields = %i[
        admin_set calc_url create_openurl csvfile ctmtime depositor document_type id
      ].freeze

      @renamed_fields = {
        doi_tesim: 'official_link'
      }.with_indifferent_access.freeze

      @excluded_fields_with_value = {
        edit_access_group_ssim: ["admin"]
      }.with_indifferent_access.freeze

      @separator_char = "|"
    end
  end
end
