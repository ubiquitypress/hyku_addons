# frozen_string_literal: true
# rubocop:disable Rails/Output
module HykuAddons
  module PortableActiveFedoraBehavior
    extend ActiveSupport::Concern

    private

      def portable_object
        puts "AF portable object"
        source_id = ActiveFedora::Base.find(arguments[0])&.source_identifier
        ::Bulkrax::Entry.find_by_identifier(source_id)
      end
  end
end
