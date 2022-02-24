# frozen_string_literal: true
# rubocop:disable Rails/Output
module HykuAddons
  module PortableBulkraxImporterBehavior
    extend ActiveSupport::Concern

    private

      def portable_object
        puts "Bulkrax Importer"
        Bulkrax::Importer.find(arguments[0])
      end
  end
end
