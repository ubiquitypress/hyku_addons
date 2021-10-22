# frozen_string_literal: true

# This form element will keep an element as multuple, `field_name[]`, but it will remove any JS
# attached to the element, so the user cannot add more. This is useful for the `title` field,
# which is supposed to be single, but backwards compatable with hyrax, where it has multiple options.
class SingleMultiValueInput < MultiValueInput
  # Changing this return value prevents the Hyrax JS from attaching to the input
  def input_type
    "single_multi_value"
  end

  def input(wrapper_options)
    @rendered_first_element = false
    input_html_classes.unshift("string")
    input_html_options[:name] ||= "#{object_name}[#{attribute_name}][]"

    buffer_each(collection) do |value, index|
      build_field(value, index)
    end
  end
end
