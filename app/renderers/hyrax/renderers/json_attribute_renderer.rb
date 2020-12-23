# frozen_string_literal: true
module Hyrax
  module Renderers
    # Overrides AttributeRenderer to allow passing in values as option
    # and calling attribute_value_to_html without calling to_s on it first
    class JsonAttributeRenderer < AttributeRenderer
      # @param [Symbol] field
      # @param [Array] values
      # @param [Hash] options
      # @option options [String] :label The field label to render
      # @option options [String] :include_empty Do we render if if the values are empty?
      # @option options [String] :work_type Used for some I18n logic
      def initialize(field, values, options = {})
        @field = field
        @values = values
        @options = options
        @values = options[:values] if options[:values].present?
      end

      # Draw the table row for the attribute
      def render
        return '' if values.blank? && !options[:include_empty]

        markup = %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)

        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")

        markup += Array(values).map do |value|
          "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value)}</li>"
        end.join

        markup += %(</ul></td></tr>)

        markup.html_safe
      end

      # Draw the dl row for the attribute
      def render_dl_row
        return '' if values.blank? && !options[:include_empty]

        markup = %(<dt>#{label}</dt>\n<dd><ul class='tabular'>)

        attributes = microdata_object_attributes(field).merge(class: "attribute attribute-#{field}")

        markup += Array(values).map do |value|
          "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value)}</li>"
        end.join
        markup += %(</ul></dd>)

        markup.html_safe
      end
    end
  end
end
