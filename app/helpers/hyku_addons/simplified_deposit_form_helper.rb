# frozen_string_literal: true

module HykuAddons
  module SimplifiedDepositFormHelper
    def form_tabs_for(form:)
      if Flipflop.enabled?(:simplified_deposit_form) && applicable?(form.model)
        super - ["doi"]
      else
        super
      end
    end

    protected

      # If the user is not an admin
      def applicable?(model)
        current_ability.can?(model.persisted? ? :edit : :create, model) && !current_user.has_role?(:admin)
      end
  end
end
