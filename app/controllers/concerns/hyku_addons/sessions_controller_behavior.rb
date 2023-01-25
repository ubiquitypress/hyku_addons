module HykuAddons
  module SessionsControllerBehavior

    WORKOS_API_KEY='sk_test_a2V5XzAxR0c3RFJIOURYM0NSNUdCTjU2Q0VCTkVDLFcxUHliQWkzd3lNOFdtZXVRbWVxT3NjNnM'
    WORKOS_CLIENT_ID='client_01GG7DRH9KVK3QNX2S6RGWA3CQ'

    def auth
      # The user's organization ID
      organization = "org_01GP3QSZ0967S8HZ9KYWT63Y1Y"

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

      # Ed? i need to know the current tennant
      user = User.find_by email: profile.email
      user = User.create email: profile.email, password: SecureRandom.hex(10) unless user   
      sign_in user
      set_jwt_cookies(user)

      redirect_to "/dashboard"
      # Use the information in `profile` for further business logic.
    end

  end
end

