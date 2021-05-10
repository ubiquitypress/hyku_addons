# frozen_string_literal: true

# Handle switching cookie domains
module HykuAddons
  module MultitenantCookieControllerBehavior
    extend ActiveSupport::Concern

    included do
      before_action :set_tenant_cookie_options
      after_action :log_tenant_cookie_options
    end

    private

      def set_tenant_cookie_options
        # Looks like we don't need this. I leave it here for now in case the nearby future proves me wrong.
        # request.env['rack.session.options'][:key] = "#{current_account&.name}_hyku_session"
        tenant_host = current_account&.frontend_url&.presence || current_account&.cname&.presence
        request.env['rack.session.options'][:domain] = ".#{tenant_host}" if tenant_host.present?
        true
      end

      def log_tenant_cookie_options
        Rails.logger.info "Cookie domain: #{request.env['rack.session.options'][:domain]}"
      end
  end
end
