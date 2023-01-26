module HykuAddons
  module SessionsControllerBehavior

    WORKOS_API_KEY=ENV["WORKOS_API_KEY"]
    WORKOS_CLIENT_ID=ENV["WORKOS_CLIENT_ID"]

    def authORGANIZATION
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

