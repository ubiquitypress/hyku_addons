# frozen_string_literal: true

require "yaml"

module Hyrax
  class SchemaGenerator
    SUBFIELDS = %i[creator contributor editor date_published].freeze

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
        @attributes[term] = build_term_attributes(term, config)
      end

      { "attributes" => @attributes }.to_yaml
    end

    protected

      def build_term_attributes(term, config)
        term_attributes = {}

        term_attributes["type"] = config.type.to_s if config.type.present?
        term_attributes["predicate"] = config.predicate.to_s
        term_attributes["multiple"] = config.multiple? if config.respond_to?(:multiple?)
        term_attributes["index_keys"] = index_keys(config.term, config.type, config.behaviors)
        term_attributes["form"] = {
          required: @form.class.required_fields.include?(term.to_sym),
          primary: @form.primary_terms.include?(term.to_sym),
          multiple: config.respond_to?(:multiple?) && config.multiple?
        }

        term_attributes["subfields"] = subfields_for(term) if SUBFIELDS.include?(term.to_sym)

        term_attributes
      end

      def index_keys(term, type, behaviors)
        Array(behaviors)
          .map { |behavior| ActiveFedora.index_field_mapper.solr_name(term, behavior, type: type) }
          .compact
          .reject(&:blank?)
          .uniq
      end

      # Try and find a file containing the subfield YAML
      def subfields_for(term)
        return unless @model.respond_to?(:json_fields) && @model.json_fields.present?

        file = File.open(HykuAddons::Engine.root.join("config", "metadata", "partials", "#{term}.yaml"))
        YAML.safe_load(file)
      rescue Errno::ENOENT
        nil
      end
  end
end
