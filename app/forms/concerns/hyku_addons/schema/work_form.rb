# frozen_string_literal: true
module HykuAddons
  module Schema
    module WorkForm
      extend ActiveSupport::Concern

      included do
        class_attribute :primary_fields, :field_configs, :internal_terms
        self.primary_fields = []
        self.required_fields = []
        self.field_configs = {}
        self.internal_terms = [] # Internal hyrax terms which don't require form fields

        def self.build_permitted_params
          super.tap do |permitted_params|
            model_class.json_fields.deep_symbolize_keys.each do |field, field_config|
              subfields = field_config[:subfields].keys.map do |subfield|
                field_config.dig(:subfields, subfield, :form, :multiple) ? { subfield => [] } : subfield
              end

              permitted_params << { field => subfields }
            end

            model_class.date_fields.each do |field|
              permitted_params << { field => ["#{field}_year".to_sym, "#{field}_month".to_sym, "#{field}_day".to_sym] }
            end
          end
        end
      end

      def schema_driven?
        true
      end

      def primary_terms
        pt = primary_fields | super
        pt += %i[admin_set_id] if Flipflop.enabled?(:simplified_admin_set_selection)
        pt
      end

      def initialize(model, current_ability, controller)
        model.admin_set_id = controller.params["admin_set_id"] if simplified_admin_set?(controller)

        super(model, current_ability, controller)
      end

      # Helper methods for JSON fields
      def creator_list
        person_or_organization_list(:creator)
      end

      def contributor_list
        person_or_organization_list(:contributor)
      end

      def editor_list
        person_or_organization_list(:editor)
      end

      def funder_list
        person_or_organization_list(:funder)
      end

      # A generic method to avoid needing a custom method for all JSON fields
      def json_field_list(field)
        person_or_organization_list(field.to_sym)
      end

      private

        def simplified_admin_set?(controller)
          Flipflop.enabled?(:simplified_admin_set_selection) && controller&.params&.dig("admin_set_id").present?
        end

        def person_or_organization_list(field)
          # Return empty hash to ensure that it gets rendered at least once
          return [{}] unless respond_to?(field) && send(field)&.first.present?

          JSON.parse(send(field).first)
        end
    end
  end
end
