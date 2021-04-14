# frozen_string_literal: true

=begin
{"access_token"=>"05a75990-b751-42f3-be97-7a9ea467d14e", "token_type"=>"bearer", "refresh_token"=>"8ffc5cd9-7f4d-48db-ae34-364cd7d0b124", "expires_in"=>631138518, "scope"=>"/read-limited /activities/update", "name"=>"Paul  Danelli", "orcid"=>"0000-0003-0652-4625"}
=end

module HykuAddons
  class UserOrcidIdentitiesController < ApplicationController
    with_themed_layout 'dashboard'
    before_action :authenticate_user!

    def new
      data = {
        client_id: ENV["ORCID_CLIENT_ID"],
        client_secret: ENV["ORCID_CLIENT_SECRET"],
        grant_type: "authorization_code",
        code: code
      }

      response = Faraday.post(helpers.orcid_token_uri, data.to_query, "Accept" => "application/json")
      body = JSON.parse(response.body)

      if response.success?
        # TODO:
        # Save the returned object to the users profile
        UserOrcidIdentity.new(body.except("name").merge(user_id: current_user.id))
        # headers = { authorization: "Bearer #{body['access_token']}", "Content-Type": "application/orcid+json" }
        # response = Faraday.get(helpers.orcid_api_uri(body["orcid"], :record), nil, headers)

        render json: response.body, status: 200
      else
        raise body["error_description"]
      end

    end

    protected

    def code
      params.require(:code)
    end

  end
end
