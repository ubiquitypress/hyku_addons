# frozen_string_literal: true
# rubocop:disable Rails/Output
module HykuAddons
  module PortableBulkraxImporterBehavior
    extend ActiveSupport::Concern

    def total_collection_entries
      portable_object
        &.importer_runs
        &.first
        &.total_collection_entries || 0
    end

    private

      def portable_object
        puts "Bulkrax Importer"
        Bulkrax::Importer.find(arguments[0])
      end
  end
end
