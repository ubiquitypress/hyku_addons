# frozen_string_literal: true
# rubocop:disable Rails/Output
module HykuAddons
  module PortableGenericBehavior
    extend ActiveSupport::Concern

    private

      def portable_object
        puts "Generic Portable"
        if arguments[0]&.source_identifier
          ::Bulkrax::Entry.find_by_identifier(arguments[0]&.source_identifier)
        else
          ::Bulkrax::Entry.find_by_identifier(arguments[0]&.id)
        end
      end
  end
end
