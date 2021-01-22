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
          "date_published" => "publication_year"
        }
      end

      def self.nested_attributes
        {
          "container" => %w[volume issue firstPage lastPage]
        }
      end

      def self.after_actions
        %i[build_related_identifiers! build_nested_attributes! update_mismatched_attributes!]
      end

      protected

        def read_creator
          get_authors(read_meta("creator")) if @meta.dig("creator").present?
        end

        def read_contributor
          get_authors(read_meta("contributor")) if @meta.dig("contributor").present?
        end

        def read_title
          read_meta("title").select(&:present?).collect { |r| { "title" => sanitize(r) } }
        end

        def read_abstract
          value = read_meta("abstract")

          return unless value.present?

          {
            "description" => sanitize(value)
          }
        end

        def read_date_published
          date = read_meta("date_published") || read_meta("date_created")&.first || read_meta("date_uploaded")
          Date.edtf(date.to_s).year

        # TODO: Remove the catch all rescue as it seems like a smell to be catching all errors
        rescue StandardError
          Time.zone.today.year
        end

        def read_keyword
          read_meta("keyword").select(&:present?).collect { |r| { "subject" => sanitize(r) } }
        end

        def read_publisher
          parse_attributes(read_meta("publisher")).to_s.strip.presence || ":unav"
        end

        def read_doi
          normalize_doi(@meta.fetch('doi', nil)&.first)
        end

        def build_related_identifiers!
          identifier_keys = %w[isbn issn eissn]

          return unless (@meta.keys & identifier_keys).present?

          @reader_attributes.merge!(
            "related_identifiers" => identifier_keys.map do |key|
              next unless (value = @meta.dig(key)).present?

              {
                "relatedIdentifier" => value,
                "relatedIdentifierType" => key.upcase,
                "relationType" => "Cites"
              }
            end.compact
          )
        end
    end
  end
end
