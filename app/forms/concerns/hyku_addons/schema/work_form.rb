# frozen_string_literal: true
module HykuAddons
  module Schema
    module WorkForm
      extend ActiveSupport::Concern

      included do
        class_attribute :primary_fields, :field_configs
        self.primary_fields = []
        self.required_fields = []
        self.field_configs = {}

        def self.build_permitted_params
          super.tap do |permitted_params|
            model_class.json_fields.each do |field, field_config|
              permitted_params << { field => field_config['subfields'].keys.map { |subfield| field_config['subfields'][subfield]['form']['multiple'] ? { subfield.to_sym => [] } : subfield.to_sym } }
            end
            model_class.date_fields.each do |field|
              permitted_params << { field => ["#{field}_year".to_sym, "#{field}_month".to_sym, "#{field}_day".to_sym] }
            end
          end
        end
      end

      def primary_terms
        pt = primary_fields | super
        pt += %i[admin_set_id] if Flipflop.enabled?(:simplified_admin_set_selection)
        pt
      end

      def initialize(model, current_ability, controller)
        model.admin_set_id = controller.params['admin_set_id'] if Flipflop.enabled?(:simplified_admin_set_selection) && controller&.params&.dig('admin_set_id').present?

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

      private

        def person_or_organization_list(field)
          # Return empty hash to ensure that it gets rendered at least once
          return [{}] unless respond_to?(field) && send(field)&.first.present?
          JSON.parse(send(field).first)
        end
    end
  end
end
