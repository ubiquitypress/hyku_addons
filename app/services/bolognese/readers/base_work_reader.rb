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
      include HykuAddons::WorkFormNameable

      DEFAULT_RESOURCE_TYPE = "Work"
      DEFAULT_META_MODEL = "GenericWork"

      # Some attributes are not copied over from data inside of hyku, but calculated in reader methods below.
      def self.special_terms
        %w[types publication_year]
      end

      # Some attributes wont match those that are expected by bolognese. This is
      # a hash map of hyku attributes to bolognese attributes, old => new
      def self.mismatched_attribute_map
        {
          "title" => "titles",
          "creator" => "creators",
          "contributor" => "contributors",
          "abstract" => "descriptions",
          "keyword" => "subjects"
        }
      end

      # A hash of keys and their array of nested attributes that need to be opperated on.
      # Each of the hash keys will be used as the key name in @reader_attributes and each array index is used as a
      # normal method to be found with `meta_values(key_name)`.
      def self.nested_attributes
        {
          "container" => %w[volume issue firstPage lastPage pagination]
        }
      end

      # An array of methods that should be called after the inital attributes have been collected.
      # These methods should modify the `@reader_attributes` variable directly
      def self.after_actions
        %i[build_related_identifiers! build_nested_attributes! build_dates! update_mismatched_attributes!]
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

        # Prepare the json to be parsed through Bolognese get_authors method
        # Bologese wants a hash with `givenName` not `creator_given_name` etc
        def bologneseify_author_json(type, json)
          creators = JSON.parse(json)
          transformed = Array.wrap(creators).map { |cr| cr.transform_keys { |k| k.gsub(/#{type}_/, "") }.deep_transform_keys { |k| k.camelize(:lower) } }

          transformed.each do |creator|
            next unless creator["orcid"].present?

            creator["nameIdentifier"] = {
              "nameIdentifierScheme" => "orcid",
              "__content__" => creator["orcid"]
            }
          end

          transformed.compact

        rescue JSON::ParserError
          json
        end

        def read_creator
          return unless (value = @meta.fetch('creator', @meta.dig('creator_display'))).present?

          value = bologneseify_author_json(:creator, value.first)

          get_authors(value)
        end

        def read_contributor
          return unless (value = @meta.fetch('contributor', @meta.dig('contributor_display'))).present?

          value = bologneseify_author_json(:contributor, value.first)

          get_authors(value)
        end

        # For now editor is treated differently to creator/contributor
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

        def read_keyword
          return unless meta_value?("keyword")

          meta_value("keyword").collect { |r| { "subject" => sanitize(r) } }
        end

        def read_publisher
          Array.wrap(meta_value("publisher")).compact.select(&:present?).first.presence || :unav
        end

        def read_doi
          normalize_doi(meta_value('doi')&.first)
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

        # Avoid overriding a parent method publication_year
        def read_publication_year
          @publication_year ||= begin
                                  date = meta_value("date_published") || meta_value("date_created")&.first || meta_value("date_uploaded")
                                  Date.edtf(date.to_s).year

                                rescue Date::Error, TypeError, NoMethodError
                                  Time.zone.today.year
                                end
        end

        def build_dates!
          dates = []

          date_fields = { date_published: "Issued", date_created: "Created", date_modified: "Updated" }
          date_fields.each do |term, denomination|
            next unless meta_value?(term)

            value = meta_value(term)
            value = value.compact.first if value.is_a?(Array)

            dates << { "date" => value, "dateType" => denomination }
          end

          @reader_attributes["dates"] = dates
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

        # Required for WorkFormNameable
        def meta_model
          @meta["has_model"] || DEFAULT_META_MODEL
        end
    end
  end
end
