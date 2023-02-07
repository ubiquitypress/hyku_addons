# frozen_string_literal: true

require "yaml"

module Hyrax
  class SchemaGenerator
    SUBFIELDS = %i[creator contributor editor funder].freeze
    FIELD_TYPE_DEFAULTS = {
      "select" => %w[resource_type license language],
      "textarea" => %w[add_info table_of_contents abstract],
      "date" => %w[date_accepted date_published date_submitted event_date related_exhibition_date]
    }.freeze
    IGNORED_FIELDS = %w[doi_status_when_public].freeze

    def initialize(model_name)
      @model = model_name.classify.safe_constantize
      @form = "Hyrax::#{@model.name}Form".safe_constantize.new(@model.new, nil, nil)
      @attributes = {}
    end

    def perform
      # NOTE - this is potentially where issues will come from as we're excluding anything that isn't part of the form
      # Order the properties as they are in the form terms
      properties = @model.properties.slice(*@form.terms.map(&:to_s))

      properties.each do |term, config|
        next if IGNORED_FIELDS.include?(term)

        @attributes[term] = field_partial_for(term) || build_term_attributes(term, config)
      end

      { "attributes" => @attributes }.to_yaml
    end

    protected

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def build_term_attributes(term, config)
      term_attributes = {}

      term_attributes["type"] = config.type.to_s if config.type.present?
      term_attributes["predicate"] = config.predicate.to_s
      term_attributes["multiple"] = config.multiple? if config.respond_to?(:multiple?)
      term_attributes["index_keys"] = index_keys(config.term, config.type, config.behaviors)
      term_attributes["form"] = {
        "required" => @form.class.required_fields.include?(term.to_sym),
        "primary" => @form.primary_terms.include?(term.to_sym),
        "multiple" => config.respond_to?(:multiple?) && config.multiple?,
        "type" => field_type_for(term)
      }

      if field_type_for(term) == "select"
        term_attributes["form"]["authority"] = authority_for(term)
        term_attributes["form"]["include_blank"] = true
      end

      term_attributes["subfields"] = subfields_for(term) if SUBFIELDS.include?(term.to_sym)

      term_attributes.compact.reject { |_k, v| v.nil? }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # Try and guess at the authority for selects
    def authority_for(term)
      return unless field_type_for(term) == "select"

      "HykuAddons::#{term.classify}Service".safe_constantize&.name
    end

    # Try and find a file containing the subfield YAML, inside the config/schema/partials folder.
    # The name of the file should match the name of the term and contain an array of subfields.
    def subfields_for(term)
      return unless @model.respond_to?(:json_fields) && @model.json_fields.present?

      field_partial_for("#{term}_subfields")
    end

    def field_partial_for(file_name)
      file = File.open(HykuAddons::Engine.root.join("config", "metadata", "partials", "#{file_name}.yaml"))
      YAML.safe_load(file)
    rescue Errno::ENOENT
      nil
    end

    # This is pretty basic, but there are not that many fields that require anything other than text
    # and the logic for the field types is in the views, so we can't do much.
    def field_type_for(term)
      FIELD_TYPE_DEFAULTS.map { |k, v| k if v.include?(term) }.compact.first || "text"
    end

    def index_keys(term, type, behaviors)
      indexes = Array(behaviors).map do |behavior|
        ActiveFedora.index_field_mapper.solr_name(term, behavior, type: type)
      end

      (indexes.presence || backup_index_keys(term, type, behaviors)).compact.reject(&:blank?).uniq
    end

    # This probably isn't necessary
    def backup_index_keys(term, type, behaviors)
      indexes = [::SolrDocument.solr_name(term)]

      Array(behaviors).map do |behavior|
        indexes << if behavior == :stored_searchable
                     "#{term}_tesim" if type == :string || type == :text
                   elsif behavior == :facetable
                     "#{term}_sim"
                   end
      end

      indexes
    end
  end
end
