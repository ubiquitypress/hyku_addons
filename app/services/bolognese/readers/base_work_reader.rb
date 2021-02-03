# frozen_string_literal: true
require 'bolognese'

# NOTE:
# Parent class to work type class readers.
# The class name is build within SolrDocumentBehavior.meta_reader_class
# and called from inside the RisContentNegotiation.export_as_ris,
# which is a concern injected into the SolrDocument
module Bolognese
  module Readers
    class BaseWorkReader < Bolognese::Metadata
      DEFAULT_RESOURCE_TYPE = "Work"

      # Some attributes are not copied over from data inside of hyku, but calculated in reader methods below.
      def self.special_terms
        %w[types]
      end

      # Some attributes wont match those that are expected by bolognese. This is
      # a hash map of hyku attributes to bolognese attributes, old => new
      def self.mismatched_attribute_map
        {
          "title" => "titles",
          "creator" => "creators",
          "contributor" => "contributors",
          "abstract" => "descriptions",
          "keyword" => "subjects",
          "date_published" => "publication_year"
        }
      end

      # A hash of keys and their array of nested attributes that need to be opperated on.
      # Each of the hash keys will be used as the key name in @reader_attributes and each array index is used as a
      # normal method to be found with `meta_values(key_name)`.
      def self.nested_attributes
        {
          "container" => %w[volume issue firstPage lastPage]
        }
      end

      # An array of methods that should be called after the inital attributes have been collected.
      # These methods should modify the `@reader_attributes` variable directly
      def self.after_actions
        %i[build_related_identifiers! build_nested_attributes! update_mismatched_attributes!]
      end

      # The primary point of interacting with the readers. The name of this method depends on what reader is specified
      # in the `from` argment on intialization: GenericWorkReader.new(input: json, from: "work")
      def read_work(string: nil, **options)
        options.except!(:doi, :id, :url, :sandbox, :validate, :ra)
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options)

        # Use an instance variable so that the method isn't passed around
        @meta = string.present? ? Maremma.from_json(string) : {}

        # Iterate over the keys within the Work Form and find values for each
        @reader_attributes = (self.class.special_terms + work_type_terms).map do |term|
          [term.to_s, term_value(term)]
        end.to_h

        perform_after_actions!

        @reader_attributes.merge(read_options)
      end

      protected

        def read_creator
          return unless (value = @meta.fetch('creator_display', @meta.dig('creator'))).present?

          get_authors(value)
        end

        def read_contributor
          return unless (value = @meta.fetch('contributor_display', @meta.dig('contributor'))).present?

          get_authors(value)
        end

        def read_editor
          return unless (value = @meta.fetch('editor_display', @meta.dig('editor'))).present?

          get_authors(value)
        end

        def read_title
          meta_value("title").collect { |r| { "title" => sanitize(r) } }
        end

        def read_abstract
          return unless meta_value?("abstract")

          {
            "description" => sanitize(meta_value("abstract"))
          }
        end

        def read_date_published
          date = meta_value("date_published") || meta_value("date_created")&.first || meta_value("date_uploaded")
          Date.edtf(date.to_s).year

          # TODO: Remove the catch all rescue as it seems like a smell to be catching all errors
        rescue StandardError
          Time.zone.today.year
        end

        def read_keyword
          return unless meta_value?("keyword")

          meta_value("keyword").collect { |r| { "subject" => sanitize(r) } }
        end

        def read_publisher
          parse_attributes(meta_value("publisher")).to_s.strip.presence || :unav
        end

        def read_doi
          normalize_doi(meta_value('doi')&.first)
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

        # This is a special method that adds some additional values to the meta object. As its not part of the
        # document form fields, we are injecting it into the meta by adding the method to the specia_methods array
        def read_types
          hyrax_resource_type = meta_value("has_model") || DEFAULT_RESOURCE_TYPE
          resource_type = meta_value("resource_type").presence || hyrax_resource_type

          {
            "resourceTypeGeneral" => "Other", # TODO: Not sure what this should be or how to work it out
            "resourceType" => resource_type,
            "hyrax" => hyrax_resource_type
          }
        end

        # Read from the meta array and try and work out what should be
        # an array and what can be returned without adjustment
        def meta_value(term)
          return unless (value = @meta.dig(term.to_s)).present?

          if work_class.multiple?(term)
            Array.wrap(value)
          else
            value
          end
        # Don't worry about methods that aren't in the form terms, just return the value and continue
        rescue ActiveFedora::UnknownAttributeError
          value
        end

        def meta_value?(term)
          meta_value(term).present?
        end

      private

        # Set a standard for term getter methods, or default to the meta value
        def term_value(term)
          read_method_name = "read_#{term}".to_sym

          respond_to?(read_method_name, true) ? send(read_method_name) : meta_value(term)
        end

        # Process any special nested attributes, like the `container` param
        def build_nested_attributes!
          self.class.nested_attributes.each do |key, terms|
            parsed_values = terms.map do |term|
              next unless (value = term_value(term)).present?

              [term, value]
            end.compact.to_h

            @reader_attributes.merge!(key => parsed_values)
          end
        end

        # Some fields are required by both Hyku and Bolognese, but their names differ.
        def update_mismatched_attributes!
          self.class.mismatched_attribute_map.each do |old, new|
            @reader_attributes[new] = @reader_attributes.delete(old)
          end
        end

        # Perform any required actions after the attributes hash has been built,
        # all actions need to updat the array
        def perform_after_actions!
          return {} unless self.class.after_actions.present?

          self.class.after_actions.each { |action| send(action.to_sym) if respond_to?(action.to_sym, true) }
        end

        def work_class
          @_work_class ||= @meta["has_model"].constantize
        end

        def work_form_class
          @_work_form_class ||= "Hyrax::#{@meta['has_model']}Form".constantize
        end

        def work_type_terms
          @_work_type_terms ||= work_form_class.terms
        end
    end
  end
end
