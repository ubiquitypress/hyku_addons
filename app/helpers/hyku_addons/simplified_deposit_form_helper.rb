# frozen_string_literal: true

module HykuAddons
  module SimplifiedDepositFormHelper
    def form_tabs_for(form:)
      if Flipflop.enabled?(:simplified_deposit_form)
        super - ["doi"]
      else
        super
      end
    end
  end
end
