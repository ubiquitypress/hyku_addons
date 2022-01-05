# frozen_string_literal: true
module HykuAddons
  module JsonifyFieldsService
    private

      def jsonify_fields(attributes, fields, field_class)
        fields.each do |field|
          remove_or_transform_field(attributes, field)
          ensure_multiple!(attributes, field, field_class)
        end
      end

      def remove_or_transform_field(attributes, field)
        if field_blank?(field, attributes[field]&.map(&:to_h))
          attributes.delete(field)
        else
          attributes[field].reject! { |o| field_blank?(field, o) } if attributes[field].is_a?(Array)
          attributes[field] = attributes[field].to_json
        end
      end

      def field_blank?(field, obj)
        name_blank?(field, obj) || recursive_blank?(obj)
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

      def ensure_multiple!(attributes, field, field_class)
        return unless field_class.multiple?(field)

        attributes[field] = Array(attributes[field])
      end
  end
end
