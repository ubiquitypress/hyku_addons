# frozen_string_literal: true

module HykuAddons
  module SimplifiedAdminSetSelectionWorkFormHelper
    def simplified_admin_set_for_form?(form:)
      return if current_user.has_role?(:admin, Site.instance)

      enabled? && permission?(form.model) && depositor?(form.depositor)
    end

    def available_admin_sets
      # Restrict available_admin_sets to only those current user can desposit to.
      @available_admin_sets ||= sources_for_deposit.map do |admin_set_id|
        [AdminSet.find(admin_set_id).title.first, admin_set_id]
      end.sort_by(&:first)
    end

    protected

      def sources_for_deposit
        options = { ability: current_ability, source_type: "admin_set" }

        Hyrax::Collections::PermissionsService.source_ids_for_deposit(options)
      end

      def enabled?
        Flipflop.enabled?(:simplified_admin_set_selection)
      end

      def permission?(model)
        current_ability.can?(model.persisted? ? :edit : :create, model)
      end

      def depositor?(depositor)
        current_user&.user_key == depositor
      end
  end
end
