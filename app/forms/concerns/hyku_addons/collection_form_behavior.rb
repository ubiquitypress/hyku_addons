# frozen_string_literal: true
module HykuAddons
  module CollectionFormBehavior
    extend ActiveSupport::Concern

    include HykuAddons::PersonOrOrganizationFormBehavior

    # TODO: extract duplicate code (from JSONFieldsActor) out into a service class?
    class_methods do
      def model_attributes(form_params)
        super.tap do |model_attributes|
          [:creator, :contributor].each do |field|
            if name_blank?(field, model_attributes[field]&.map(&:to_h)) || recursive_blank?(model_attributes[field]&.map(&:to_h))
              model_attributes.delete(field)
            else
              model_attributes[field] = model_attributes[field].to_json
            end
            model_attributes[field] = Array(model_attributes[field]) if multiple?(field)
          end
        end
      end

      def name_blank?(field, obj)
        return false unless field.in? [:creator, :contributor, :editor]
        recursive_blank?(Array(obj).map { |o| o.reject { |k, _v| k == "#{field}_name_type" } })
      end

      def recursive_blank?(obj)
        case obj
        when Hash
          obj.values.all? { |o| recursive_blank?(o) }
        when Array
          obj.all? { |o| recursive_blank?(o) }
        else
          obj.blank?
        end
      end
    end
  end
end
