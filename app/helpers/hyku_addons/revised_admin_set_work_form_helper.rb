# frozen_string_literal: true

module HykuAddons
  module RevisedAdminSetWorkFormHelper
    PACIFIC = "Pacific"
    REVISED_TABS = ["relationships"].freeze

    def form_tabs_for(form:)
      if pacific_account? && pacific_form?(form) && can_edit?(form) && depositor?(form)
        return super - REVISED_TABS
      end

      super
    end

    protected

    def pacific_form?(form)
      form.model_class.name.match?(PACIFIC)
    end

    def pacific_account?
      current_account.name == PACIFIC
    end

    def can_edit?(form)
      current_ability.can?(:edit, form.model)
    end

    def depositor?(form)
      current_user.user_key == form.depositor
    end
  end
end
