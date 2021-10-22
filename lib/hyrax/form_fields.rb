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
    # These are the internal fields that Hyrax uses to create its forms, however they also set
    # a bunch of actual input fields, which we may not want and can't remove later.
    INTERNAL_FIELDS = %i[representative_id thumbnail_id rendering_ids files
                    visibility_during_embargo embargo_release_date visibility_after_embargo
                    visibility_during_lease lease_expiration_date visibility_after_lease
                    visibility ordered_member_ids source in_works_ids
                    member_of_collection_ids admin_set_id].freeze

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
        next unless attributes[d].key?('subfields')

        definitions[d]['subfields'] = attributes[d]['subfields'].transform_values { |subfield| subfield['form'] }
      end

      definitions
    end

    ##
    # @return [String]
    def inspect
      "#{self.class}(#{@name})"
    end

    private

      def included(descendant)
        super

        # Reset the fields as we might not want all fo the Hyrax defaults.
        # To reset the default behavior and default fields, remove this line.
        descendant.terms = INTERNAL_FIELDS

        form_field_definitions.each do |field_name, options|
          descendant.terms += [field_name.to_sym]
          descendant.required_fields += [field_name.to_sym] if options[:required]
          descendant.primary_fields += [field_name.to_sym] if options[:primary]
          descendant.field_configs[field_name.to_sym] = options
        end
      end
  end
end
