# frozen_string_literal: true

module Hyrax
  ##
  # @api public
  #
  # @param [Symbol] schema_name
  #
  # @since 3.0.0
  def self.FormFields(schema_name, **options)
    Hyrax::FormFields.new(schema_name, **options)
  end

  ##
  # @api private
  #
  # @see .FormFields
  class FormFields < Module
    attr_reader :name

    ##
    # @api private
    #
    # @param [Symbol] schema_name
    # @param [#form_definitions_for] definition_loader
    #
    # @note use Hyrax::FormFields(:my_schema) instead
    def initialize(schema_name, definition_loader: SimpleSchemaLoader.new)
      @name = schema_name
      @definition_loader = definition_loader
    end

    ##
    # @return [Hash{Symbol => Hash{Symbol => Object}}]
    def form_field_definitions
      definitions = @definition_loader.form_definitions_for(schema: name)
      attributes = @definition_loader.attributes_config_for(schema: name)

      definitions.each_key do |d|
        next unless attributes[d].key?("subfields")

        definitions[d]["subfields"] = attributes[d]["subfields"].transform_values { |subfield| subfield["form"] }
      end

      definitions.deep_symbolize_keys!
    end

    ##
    # @return [String]
    def inspect
      "#{self.class}(#{@name})"
    end

    private

    def included(descendant)
      super

      # Maintain a list of internal terms to help prevent them from being rendered as fields on the form
      descendant.internal_terms = descendant.terms.difference(form_field_definitions.keys).sort
      remove_skippable!(descendant)

      form_field_definitions.each do |field_name, options|
        # Ensure we don"t get duplicate entries
        descendant.terms += [field_name] unless descendant.terms.include?(field_name)
        descendant.required_fields += [field_name] if options[:required]
        descendant.primary_fields += [field_name] if options[:primary]
        descendant.field_configs[field_name] = options
      end

      ensure_ordered!(descendant)

      # Changes to these configurations will be maintained until the server is restarted, so should never happen
      descendant.terms.freeze
      descendant.required_fields.freeze
      descendant.primary_fields.freeze
      descendant.field_configs.freeze
    end

    # If we have a default Hyrax field which is not included in our schema definition, it should be removed
    def remove_skippable!(descendant)
      similar = internal_skippable_fields & form_field_definitions.keys

      descendant.terms = descendant.terms - (internal_skippable_fields - similar)
    end

    # Ensure that the terms are ordered by the original definitions after hyrax adds its own in
    def ensure_ordered!(descendant)
      descendant.terms.sort_by!(&field_orderer)
      descendant.primary_fields.sort_by!(&field_orderer)
    end

    # Define a list of internal Hyrax form fields, which might not be required by a schema and it is safe to skip.
    def internal_skippable_fields
      %i[creator contributor description keyword license rights_statement publisher language identifier based_near related_url]
    end

    def field_orderer
      ->(term) { form_field_definitions.keys.index(term) || Float::INFINITY }
    end
  end
end
