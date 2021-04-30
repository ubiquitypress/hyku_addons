# frozen_string_literal: true
#
Warden::Manager.before_logout do |user, auth, _opts|
  HykuAddons::JwtCookiesService.new(user, auth).remove_jwt_cookies
end

Warden::Manager.after_authentication do |user, auth, _opts|
  HykuAddons::JwtCookiesService.new(user, auth).set_jwt_cookies
end
