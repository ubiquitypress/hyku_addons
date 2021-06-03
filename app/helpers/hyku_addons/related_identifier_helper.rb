# frozen_string_literal: true
module HykuAddons
  module CreatorFieldHelper
    def related_identifier_new_input_for(template)
      text_field_tag "#{template}[related_identifier][][related_identifier]", nil,
                     class: "#{template}_related_identifier form-control multi-text-field multi_value related_identifier",
                     name: "#{template}[related_identifier][][related_identifier]",
                     placeholder: t("simple_form.placeholders.defaults.related_identifier")
    end

    def related_identifier_edit_input_for(template, hash)
      text_field_tag "#{template}[related_identifier][][related_identifier]", hash.dig("related_identifier"),
                     class: "#{template}_related_identifier form-control multi-text-field multi_value related_identifier",
                     name: "#{template}[related_identifier][][related_identifier]",
                     placeholder: t("simple_form.placeholders.defaults.related_identifier")
    end
  end
end
