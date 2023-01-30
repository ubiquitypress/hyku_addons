# frozen_string_literal: true
module HykuAddons
  module Schema
    module WorkForm
      extend ActiveSupport::Concern

      include HykuAddons::NoteFormBehavior

      included do
        class_attribute :primary_fields, :field_configs, :internal_terms
        self.primary_fields = []
        self.required_fields = []
        self.field_configs = {}
        self.internal_terms = [] # Internal hyrax terms which don't require form fields

        # disable rubocop because we can refactor this method at a later time
        # rubocop:disable Metrics/MethodLength
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

            # to address saving of any old field that was single but changed to multiple
            ["rights_statement"].each do |field|
              next unless field_configs.dig(field.to_sym, :multiple)
              permitted_params << { field => [] }
            end
          end
        end
        # rubocop:enable Metrics/MethodLength
      end

      def initialize(model, current_ability, controller)
        model.admin_set_id = controller.params["admin_set_id"] if simplified_admin_set?(controller)

        super(model, current_ability, controller)
      end

      def schema_driven?
        true
      end

      def primary_terms
        pt = primary_fields | super
        pt += %i[admin_set_id] if Flipflop.enabled?(:simplified_admin_set_selection)
        pt += %i[doi]

        pt.uniq
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
