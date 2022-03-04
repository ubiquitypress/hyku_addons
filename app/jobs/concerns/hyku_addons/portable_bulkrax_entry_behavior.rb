# frozen_string_literal: true
# rubocop:disable Rails/Output
module HykuAddons
  module PortableBulkraxEntryBehavior
    extend ActiveSupport::Concern

    private

      def portable_object
        puts "Bulkrax Portable"
        # Collections cannot be found by identifier
        ::Bulkrax::Entry.find(arguments[0])
      end
  end
end
