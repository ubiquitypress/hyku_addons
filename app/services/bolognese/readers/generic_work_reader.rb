# frozen_string_literal: true
# Use this with Bolognese like the following:
#
# json = Hyrax::GenericWorkPresenter::DELEGATED_METHODS.collect { |m|
#   [m, p.send(m)]
# }.to_h.merge('has_model' => p.model.model_name).to_json
# Bolognese::Readers::GenericWorkReader.new(input: json, from: 'generic_work')
#
# Then crosswalk it with:
# m.datacite
# Or:
# m.ris
module Bolognese
  module Readers
    class GenericWorkReader < BaseWorkReader
      # Some attributes wont match those that are expected by bolognese. This is
      # a hash map of hyku attributes to bolognese attributes, old => new
      def self.mismatched_attribute_map
        {
          "title" => "titles",
          "creator" => "creators",
          "abstract" => "descriptions",
          "keyword" => "subjects",
          "date_published" => "publication_year",
        }
      end

      def self.nested_attributes
        {
          "container" => %w[volume issue firstPage lastPage],
        }
      end

      def self.after_actions
        %i[build_nested_attributes!] + super
      end

      def build_related_identifiers!
        identifier_keys = %w[isbn issn eissn]

        return unless (@meta.keys & identifier_keys).present?

        @reader_attributes.merge!({
          "related_identifiers" => identifier_keys.map { |key|
            next unless (value = @meta.dig(key)).present?

            {
              "relatedIdentifier" => value,
              "relatedIdentifierType" => key.upcase,
              "relationType" => "Cites",
            }
          }.compact
        })
      end

    end
  end
end
