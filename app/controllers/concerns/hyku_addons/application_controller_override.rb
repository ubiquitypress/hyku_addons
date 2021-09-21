# frozen_string_literal: true

# Stops redirection to dashboard features
module HykuAddons
  module ApplicationControllerOverride
    extend ActiveSupport::Concern

    private

      def require_active_account!
        return unless Settings.multitenancy.enabled
        return if devise_controller?

        # To avoid ActionController::RoutingError (Not Found) when
        # updating flipflop from proprietor account ui
        return if request.path.include?  "/admin/features"
        raise Apartment::TenantNotFound, "No tenant for #{request.host}" unless current_account.persisted?
      end
  end
end
