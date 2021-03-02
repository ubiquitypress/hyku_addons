# frozen_string_literal: true

module HykuAddons
  module RevisedAdminSetWorkFormHelper
    REVISED_TABS = ["relationships"].freeze

    def form_tabs_for(form:)
      if Flipflop.enabled?(:revised_admin_set_layout) && can_edit?(form) && depositor?(form)
        return super - REVISED_TABS
      end

      super
    end

    def available_admin_sets
      # Restrict available_admin_sets to only those current user can desposit to.
      @available_admin_sets ||= sources_for_deposit.map do |admin_set_id|
        [AdminSet.find(admin_set_id).title.first, admin_set_id]
      end
    end

    protected

    def sources_for_deposit
      Hyrax::Collections::PermissionsService.source_ids_for_deposit(ability: current_ability, source_type: 'admin_set')
    end

    def can_edit?(form)
      current_ability.can?(:edit, form.model)
    end

    def depositor?(form)
      current_user.user_key == form.depositor
    end
  end
end
