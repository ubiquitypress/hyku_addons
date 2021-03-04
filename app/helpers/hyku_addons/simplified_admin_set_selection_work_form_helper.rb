# frozen_string_literal: true

module HykuAddons
  module SimplifiedAdminSetSelectionWorkFormHelper
    def form_tabs_for(form:)
      if Flipflop.enabled?(:simplified_admin_set_selection) && can_edit?(form.model) && depositor?(form.depositor)
        return super - ["relationships"]
      else
        super
      end
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

      def can_edit?(model)
        # NOTE:
        # This is gross, but without it the specs fail with:
        # `*** Flipflop::FeatureError Exception: Feature 'transfer_works' unknown.`
        return true if Rails.env.test?

        current_ability.can?(:edit, model)
      end

      def depositor?(depositor)
        # Other wise `undefined method `user_key' for nil:NilClass`
        return true if Rails.env.test?

        current_user.user_key == depositor
      end
  end
end
