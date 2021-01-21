# frozen_string_literal: true
require 'bolognese'

module Bolognese
  module Readers
    class BaseWorkReader < Bolognese::Metadata
      def self.nested_attributes
        {
          container: %i[volume issue first_page last_page],
        }
      end

      def self.after_actions
        %i[build_types! build_nested_attributes! build_related_identifiers!]
      end

      def read_work(string: nil, **options)
        options.except!(:doi, :id, :url, :sandbox, :validate, :ra)
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options)

        @meta = string.present? ? Maremma.from_json(string) : {}

        reader_attributes.merge(read_options)
      end

      protected

        def reader_attributes
          @reader_attributes = work_type_terms.map { |term| [term, term_value(term)] }.to_h

          perform_after_actions!

          @reader_attributes
        end

        def work_form_class
          @_work_form_class ||= "Hyrax::#{@meta["has_model"]}Form".constantize
        end

        def work_type_terms
          @_work_type_terms ||= work_form_class.terms
        end

        # Set a standard for term getter methods, or default to the meta value
        def term_value(term)
          read_method_name = "read_#{term}".to_sym

          respond_to?(read_method_name, true) ? send(read_method_name) : read_meta(term)
        end

        def read_meta(term)
          @meta.dig(term.to_s)
        end

        # Perform any required actions after the attributes hash has been built, all actions need to updat the array
        def perform_after_actions!
          return {} unless self.class.after_actions.present?

          self.class.after_actions.each { |action| send(action.to_sym) if respond_to?(action.to_sym, true) }
        end

        def build_types!
          hyrax_resource_type = read_meta('has_model') || "Work"
          resource_type = read_meta('resource_type').presence || hyrax_resource_type

          @reader_attributes.merge!({
            "resourceTypeGeneral" => "Other",
            "resourceType" => resource_type,
            "hyrax" => hyrax_resource_type
          }.compact)
        end

        def build_nested_attributes!
          self.class.nested_attributes.each do |key, terms|
            parsed_values = terms.map do |term|
              next unless (value = term_value(term)).present?

              [term, value]
            end.compact.to_h

            @reader_attributes.merge!(key => parsed_values)
          end
        end

        def build_related_identifiers!
          identifier_keys = %w[isbn issn eissn]

          return unless (@meta.keys & identifier_keys).present?

          @reader_attributes.merge!({
            related_identifiers: identifier_keys.map { |key|
              next unless (value = @meta.dig(key)).present?

              {
                "relatedIdentifier" => value,
                "relatedIdentifierType" => key.upcase,
                "relationType" => "Cites",
              }
            }.compact
          })
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

        def read_doi
          normalize_doi(@meta.fetch('doi', nil)&.first)
        end
    end
  end
end
