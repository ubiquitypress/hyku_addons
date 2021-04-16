# frozen_string_literal: true
#
# API Request
#
# headers = { authorization: "Bearer #{body['access_token']}", "Content-Type": "application/orcid+json" }
# response = Faraday.get(helpers.orcid_api_uri(body["orcid"], :record), nil, headers)

module Hyrax
  class OrcidIdentitiesController < ApplicationController
    with_themed_layout 'dashboard'
    before_action :authenticate_user!

    def new
      request_authorization

      current_user.orcid_identity_from_authorization(authorization_body) if @authorization_response.success?

      render json: authorization_body, status: @authorization_response.status
    end

    protected

      def request_authorization
        data = {
          client_id: ENV["ORCID_CLIENT_ID"],
          client_secret: ENV["ORCID_CLIENT_SECRET"],
          grant_type: "authorization_code",
          code: code
        }

        @authorization_response = Faraday.post(helpers.orcid_token_uri, data.to_query, "Accept" => "application/json")
      end

      def authorization_body
        JSON.parse(@authorization_response.body)
      end

      def code
        params.require(:code)
      end
  end
end
