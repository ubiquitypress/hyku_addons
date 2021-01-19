# frozen_string_literal: true
require 'bolognese'

module Bolognese
  module Readers
    class BaseWorkReader < Bolognese::Metadata
      def read_work(string: nil, **options)
        options.except!(:doi, :id, :url, :sandbox, :validate, :ra)
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options)

        @meta = string.present? ? Maremma.from_json(string) : {}
        reader_attributes.merge(read_options)
      end

      protected

        def reader_attributes
          {
            "identifiers" => read_identifiers,
            "types" => read_types,
            "doi" => normalize_doi(@meta.fetch('doi', nil)&.first),
            "titles" => read_titles,
            "creators" => read_creators,
            "contributors" => read_contributors,
            "publisher" => read_publisher,
            "publication_year" => read_publication_year,
            "place_of_publication" => read_place_of_publication,
            "descriptions" => read_descriptions,
            "subjects" => read_subjects,
            "language" => read_language,
            "editor" => read_editor,
            "journal_title" => read_journal_title,
            "add_info" => read_add_info,
            "official_link" => read_official_link,
            "container" => {
              "volume" => read_volume,
              "issue" => read_issue,
              "firstPage" => nil,
              "lastPage" => nil,
              # FIXME: The order doesn't seem to be preserved so how can we have T1 and T2?
              # "title" => alt_title,
            },
            "related_identifiers" => [
              {
                "relatedIdentifier" => @meta.dig("issn"),
                "relatedIdentifierType" => "ISSN",
                "relationType" => "IsPartOf",
                "resourceTypeGeneral" => "Collection"
              },
              {
                "relatedIdentifier" => @meta.dig("isbn"),
                "relatedIdentifierType" => "ISBN",
                "relationType" => "IsPartOf",
                "resourceTypeGeneral" => "Collection"
              }
            ]
          }
        end

        def read_types
          hyrax_resource_type = @meta.dig('has_model') || "Work"
          resource_type = @meta.dig('resource_type').presence || hyrax_resource_type

          {
            "resourceTypeGeneral" => "Other",
            "resourceType" => resource_type,
            "hyrax" => hyrax_resource_type
          }.compact
        end

        def read_creators
          get_authors(Array.wrap(@meta.dig("creator"))) if @meta.dig("creator").present?
        end

        def read_contributors
          get_authors(Array.wrap(@meta.dig("contributor"))) if @meta.dig("contributor").present?
        end

        def read_language
          Array.wrap(@meta.dig("language")) if @meta.dig("language").present?
        end

        def read_place_of_publication
          Array.wrap(@meta.dig("place_of_publication")) if @meta.dig("place_of_publication").present?
        end

        def read_official_link
          Array.wrap(@meta.dig("official_link")) if @meta.dig("official_link").present?
        end

        def read_add_info
          Array.wrap(@meta.dig("add_info")) if @meta.dig("add_info").present?
        end

        def read_editor
          Array.wrap(@meta.dig("editor")) if @meta.dig("editor").present?
        end

        def read_issue
          Array.wrap(@meta.dig("issue")) if @meta.dig("issue").present?
        end

        def read_volume
          Array.wrap(@meta.dig("volume")) if @meta.dig("volume").present?
        end

        def read_journal_title
          Array.wrap(@meta.dig("journal_title")) if @meta.dig("journal_title").present?
        end

        def read_titles
          Array.wrap(@meta.dig("title")).select(&:present?).collect { |r| { "title" => sanitize(r) } }
        end

        def read_descriptions
          Array.wrap(@meta.dig("description")).select(&:present?).collect { |r| { "description" => sanitize(r) } }
        end

        def read_publication_year
          date = @meta.dig("date_created")&.first || @meta.dig("date_uploaded")
          Date.edtf(date.to_s).year

        # TODO: Remove the catch all rescue as it seems like a smell to be catching all errors
        rescue StandardError
          Time.zone.today.year
        end

        def read_subjects
          Array.wrap(@meta.dig("keyword")).select(&:present?).collect { |r| { "subject" => sanitize(r) } }
        end

        def read_identifiers
          Array.wrap(@meta.dig("identifier")).select(&:present?).collect { |r| { "identifier" => sanitize(r) } }
        end

        def read_publisher
          # Fallback to ':unav' since this is a required field for datacite
          # TODO: Should this default to application_name?
          parse_attributes(@meta.dig("publisher")).to_s.strip.presence || ":unav"
        end
    end
  end
end
