# frozen_string_literal: true
require 'bolognese'

module Bolognese
  module Readers
    class BaseWorkReader < Bolognese::Metadata
      def read_work(string: nil, **options)
        options.except!(:doi, :id, :url, :sandbox, :validate, :ra)
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options)

        meta = string.present? ? Maremma.from_json(string) : {}

        reader_attributes(meta).merge(read_options)
      end

      protected

        def reader_attributes(meta)
          {
            "identifiers" => read_identifiers(meta),
            "types" => read_types(meta),
            "doi" => normalize_doi(meta.fetch('doi', nil)&.first),
            "titles" => read_titles(meta),
            "creators" => read_creators(meta),
            "contributors" => read_contributors(meta),
            "publisher" => read_publisher(meta),
            "publication_year" => read_publication_year(meta),
            "descriptions" => read_descriptions(meta),
            "subjects" => read_subjects(meta)
          }
        end

        def read_types(meta)
          # TODO: Map work.resource_type or work.
          resource_type_general = "Other"
          hyrax_resource_type = meta.fetch('has_model', nil) || "Work"
          resource_type = meta.fetch('resource_type', nil).presence || hyrax_resource_type
          {
            "resourceTypeGeneral" => resource_type_general,
            "resourceType" => resource_type,
            "hyrax" => hyrax_resource_type
          }.compact
        end

        def read_creators(meta)
          get_authors(Array.wrap(meta.fetch("creator_display", nil))) if meta.fetch("creator_display", nil).present?
        end

        def read_contributors(meta)
          get_authors(Array.wrap(meta.fetch("contributor", nil))) if meta.fetch("contributor", nil).present?
        end

        def read_titles(meta)
          Array.wrap(meta.fetch("title", nil)).select(&:present?).collect { |r| { "title" => sanitize(r) } }
        end

        def read_descriptions(meta)
          Array.wrap(meta.fetch("description", nil)).select(&:present?).collect { |r| { "description" => sanitize(r) } }
        end

        def read_publication_year(meta)
          date = meta.dig("date_created")&.first || meta.dig("date_uploaded")
          Date.edtf(date.to_s).year

        # TODO: Remove the catch all rescue as it seems like a smell to be catching all errors
        rescue StandardError
          Time.zone.today.year
        end

        def read_subjects(meta)
          Array.wrap(meta.fetch("keyword", nil)).select(&:present?).collect { |r| { "subject" => sanitize(r) } }
        end

        def read_identifiers(meta)
          Array.wrap(meta.fetch("identifier", nil)).select(&:present?).collect { |r| { "identifier" => sanitize(r) } }
        end

        def read_publisher(meta)
          # Fallback to ':unav' since this is a required field for datacite
          # TODO: Should this default to application_name?
          parse_attributes(meta.fetch("publisher")).to_s.strip.presence || ":unav"
        end
    end
  end
end
