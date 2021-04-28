# frozen_string_literal: true

# Overrides Hyrax methods to handle multitenant overrides of I18n locale
module HykuAddons
  module MultitenantCookieControllerBehavior
    extend ActiveSupport::Concern

    included do
      before_action :set_tenant_cookie_options
    end

    private

      def set_tenant_cookie_options
        # Looks like we don't need this. I leave it here for now in case the nearby future proves me wrong.
        # request.env['rack.session.options'][:key] = "#{current_account&.name}_hyku_session"
        request.env['rack.session.options'][:domain] = ".#{current_account&.frontend_url || current_account&.cname}"
      end
  end
end
