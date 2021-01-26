# frozen_string_literal: true
module Hyrax
  module Renderers
    class DepositFormFieldHintRenderer
      def hint(key = "")
        help_key = "simple_form.hints.defaults.#{key}"
        "<p class='help-block'>#{I18n.t(help_key)}</p>".html_safe if I18n.exists?(help_key)
      end
    end
  end
end
