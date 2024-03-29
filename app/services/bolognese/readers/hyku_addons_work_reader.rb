# frozen_string_literal: true

require "bolognese"

module Bolognese
  module Readers
    module HykuAddonsWorkReader
      extend ActiveSupport::Concern

      include HykuAddons::WorkFormNameable
      include ::HykuAddons::Bolognese::JsonFieldsReader

      DEFAULT_RESOURCE_TYPE = "Work"
      DEFAULT_META_MODEL = "GenericWork"

      class_methods do
        # Some attributes are not copied over from data inside of hyku, but calculated in reader methods below.
        def special_terms
          %w[types publication_year]
        end

        # Some attributes wont match those that are expected by bolognese. This is
        # a hash map of hyku attributes to bolognese attributes, old => new
        def mismatched_attribute_map
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
        def nested_attributes
          {
            "container" => %w[volume issue firstPage lastPage pagination]
          }
        end

        # An array of methods that should be called after the inital attributes have been collected.
        # These methods should modify the `@reader_attributes` variable directly
        def after_actions
          %i[set_work_id! build_related_identifiers! build_nested_attributes! build_dates! update_mismatched_attributes!]
        end
      end

      # The primary point of interacting with the readers. The name of this method depends on what reader is specified
      # in the `from` argment on intialization: Bolognese::Metadata.new(input: json, from: "hyku_addons_work")
      def read_hyku_addons_work(string: nil, **options)
        options.except!(:doi, :id, :url, :sandbox, :validate, :ra)
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options)

        # Use an instance variable so that the method isn't passed around
        @meta = string.present? ? Maremma.from_json(string) : {}

        # Iterate over the keys within the Work Form and find values for each
        @reader_attributes = (self.class.special_terms + work_type_terms(reader_model)).map do |term|
          [term.to_s, term_value(term)]
        end.to_h

        perform_after_actions!

        @reader_attributes.merge(read_options)
      end

      protected

      def read_creator
        return if (value = @meta.fetch("creator", @meta.dig("creator_display"))).blank?

        value = bologneseify_author_json(:creator, value.first)

        get_authors(value)
      end

      def read_contributor
        return if (value = @meta.fetch("contributor", @meta.dig("contributor_display"))).blank?

        value = bologneseify_author_json(:contributor, value.first)

        get_authors(value)
      end

      # For now editor is treated differently to creator/contributor because we don't have a specific example
      # where this should be adjusted. This will likely change as a client provides a useful example.
      def read_editor
        return if (value = @meta.fetch("editor_display", @meta.dig("editor"))).blank?

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
        Array.wrap(meta_value("publisher")).compact.find(&:present?).presence || :unav
      end

      def read_doi
        normalize_doi(meta_value("doi")&.first)
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

      def set_work_id!
        @reader_attributes["id"] = @meta["id"]
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

        return if (@meta.keys & identifier_keys).blank?

        @reader_attributes.merge!(
          "related_identifiers" => identifier_keys.map do |key|
            next if (value = @meta.dig(key)).blank?

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
        return if (value = @meta.dig(term.to_s)).blank?

        if work_class(reader_model).multiple?(term)
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
            next if (value = term_value(term)).blank?

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
        return {} if self.class.after_actions.blank?

        self.class.after_actions.each { |action| send(action.to_sym) if respond_to?(action.to_sym, true) }
      end

      # Required for WorkFormNameable
      def reader_model
        @meta["has_model"] || DEFAULT_META_MODEL
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
