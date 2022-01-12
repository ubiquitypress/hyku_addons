# frozen_string_literal: true

# Stops redirection to dashboard features
module HykuAddons
  module ApplicationControllerOverride
    extend ActiveSupport::Concern

    included do
      rescue_from RuntimeError, with: :blacklight_adapter_error
    end

    private

      # Try and resue the blacklight errors we have been seeing. However, this will likely either work, or move the
      # error elsewhere within Sentry, so this should be considered a temporary fix at best.
      def blacklight_adapter_error(error)
        raise error unless error.message == "The value for :adapter was not found in the blacklight.yml config"

        # I'm not 100% sure which to set, so I'm setting both
        Blacklight.connection_config[:adapter] = "solr"
        Blacklight.repository_class = Blacklight::Solr::Repository
      end

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
