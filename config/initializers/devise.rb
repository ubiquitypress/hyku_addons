# frozen_string_literal: true
#
Warden::Manager.before_logout do |user, auth, _opts|
  current_account = Account.find_by_cname auth.request.host
  tenant_host = current_account&.frontend_url&.presence || current_account&.cname&.presence
  auth.request.env['rack.session.options'][:domain] = ".#{tenant_host}" if tenant_host.present?
  HykuAddons::JwtCookiesService.new(user, auth).remove_jwt_cookies
end

Warden::Manager.after_authentication do |user, auth, _opts|
  HykuAddons::JwtCookiesService.new(user, auth).set_jwt_cookies
end
