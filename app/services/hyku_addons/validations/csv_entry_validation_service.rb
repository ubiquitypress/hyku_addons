# frozen_string_literal: true
module HykuAddons
  module Validations
    class CsvEntryValidationService < EntryValidationService
      def destination_metadata
        @_destination_metadata ||= @entry.clone.build_export_metadata
      end
    end
  end
end
