# frozen_string_literal: true

# Manages the JWT authentication cookies based on Warden callbacks.
module HykuAddons
  class JwtCookiesService
    JWT_SECRET = Rails.application.secrets.secret_key_base

    def initialize(user, env)
      @user = user
      @account = Account.from_request(env.request)
      @cookie_jar = env.cookies
      @request = env.request
    end

    def set_jwt_cookies(user = nil)
      user ||= @user
      set_jwt_cookie(:jwt, value: generate_token(user_id: user.id, type: user_roles(user)), expires: 1.week.from_now)
      set_jwt_cookie(:refresh, value: generate_token(user_id: user.id, exp: 1.week.from_now.to_i), expires: 1.week.from_now)
    end

    def remove_jwt_cookies
      Rails.logger.info @account
      Rails.logger.info cookie_domain
      %i[jwt refresh].each do |cookie|
        set_jwt_cookie(cookie, value: '', expires: 10_000.hours.ago)
      end
    end

    private

      def set_jwt_cookie(name, options)
        @cookie_jar[name] = default_cookie_options.merge(options)
      end

      def generate_token(payload = {})
        JWT.encode(payload.reverse_merge(exp: (Time.now.utc + 1.hour).to_i), JWT_SECRET)
      end

      def default_cookie_options
        {
          path: '/',
          same_site: :lax,
          domain: ('.' + cookie_domain),
          secure: Rails.env.production?,
          httponly: true
        }
      end

      def cookie_domain
        @account.attributes.with_indifferent_access[:frontend_url].presence || @request.host
      end

      def user_roles(user)
        # Need to call `.uniq` because admin role can appear twice
        user.roles.map(&:name).uniq - ['super_admin']
      end
  end
end
