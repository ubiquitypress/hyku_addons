# frozen_string_literal: true
module HykuAddons
  module SessionsControllerBehavior
    WORKOS_API_KEY = ENV["WORKOS_API_KEY"]
    WORKOS_CLIENT_ID = ENV["WORKOS_CLIENT_ID"]

    def auth
      # The user's organization ID
      organization = ENV["ORGANIZATION_UID"]
      # The callback URI WorkOS should redirect to after the authentication
      redirect_uri = "https://#{request.host}/sso/callback"
      authorization_url = WorkOS::SSO.authorization_url(
        client_id: WORKOS_CLIENT_ID,
        organization: organization,
        redirect_uri: redirect_uri
      )

      redirect_to authorization_url
    end

    def callback
      profile_and_token = WorkOS::SSO.profile_and_token(
        code: params["code"],
        client_id: WORKOS_CLIENT_ID
      )

      profile = profile_and_token.profile

      password = SecureRandom.hex(10)

      user = User.find_or_create_by(email: profile.email).tap do |u|
        u.password = password
        u.password_confirmation = password
        u.email = profile.email
      end

      sign_in user

      set_jwt_cookies(user)

      redirect_to "/dashboard"
      # Use the information in `profile` for further business logic.
    end
  end
end
