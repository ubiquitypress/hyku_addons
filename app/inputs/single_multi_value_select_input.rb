# frozen_string_literal: true

# This form element will keep an element as multuple, `field_name[]`, but it will remove any JS
# attached to the element, so the user cannot add more. This is useful for the `title` field,
# which is supposed to be single, but backwards compatable with hyrax, where it has multiple options.
class SingleMultiValueSelectInput < MultiValueSelectInput
  # Changing this return value prevents the Hyrax JS from attaching to the input
  def input_type
    "single_multi_value"
  end
end
