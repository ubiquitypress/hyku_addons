# frozen_string_literal: true
require 'bolognese'

module Bolognese
  module Readers
    # Use this with Bolognese like the following:
    # json = Hyrax::GenericWorkPresenter::DELEGATED_METHODS.collect {|m| [m, p.send(m)]}.to_h.merge('has_model' => p.model.model_name).to_json
    # m = Bolognese::Metadata.new(input: json, from: 'generic_work')
    # Then crosswalk it with:
    # m.datacite
    # Or:
    # m.ris
    class GenericWorkReader < Bolognese::Metadata
      def read_generic_work(string: nil, **options)
        options.except!(:doi, :id, :url, :sandbox, :validate, :ra)
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options)

        meta = string.present? ? Maremma.from_json(string) : {}

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
        }.merge(read_options)
      end

      private

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
          date = meta.fetch("date_created", nil)&.first
          date ||= meta.fetch("date_uploaded", nil)
          Date.edtf(date.to_s).year
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
