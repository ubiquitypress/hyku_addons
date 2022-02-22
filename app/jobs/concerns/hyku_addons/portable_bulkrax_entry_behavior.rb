# frozen_string_literal: true
# rubocop:disable Rails/Output
module HykuAddons
  module PortableBulkraxEntryBehavior
    extend ActiveSupport::Concern

    private

      def portable_object
        puts "Bulkrax Portable"
        Bulkrax::Entry.find_by_identifier(arguments[0])
      end
  end
end
