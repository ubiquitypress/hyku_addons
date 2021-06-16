# frozen_string_literal: true
#
# API Request
#
# headers = { authorization: "Bearer #{body['access_token']}", "Content-Type": "application/orcid+json" }
# response = Faraday.get(helpers.orcid_api_uri(body["orcid"], :record), nil, headers)

module Hyrax
  module Dashboard
    module Orcid
      class OrcidIdentitiesController < ApplicationController
        with_themed_layout "dashboard"
        before_action :authenticate_user!

        def new
          request_authorization

          current_user.orcid_identity_from_authorization(authorization_body)

          if authorization_success?
            flash[:notice] = I18n.t("orcid_identity.preferences.create.success")
          else
            flash[:error] = I18n.t("orcid_identity.preferences.create.failure")
          end

          redirect_to dashboard_profile_path(current_user)
        end

        def update
          if current_user.orcid_identity.update(permitted_preference_params)
            flash[:notice] = I18n.t("orcid_identity.preferences.update.success")
          else
            flash[:error] = I18n.t("orcid_identity.preferences.update.failure")
          end

          redirect_back fallback_location: dashboard_profile_path(current_user)
        end

        def destroy
          # This is pretty ugly, but for a has_one relation we can't do a find_by! from User
          raise ActiveRecord::RecordNotFound unless current_user.orcid_identity.id == params["id"].to_i

          current_user.orcid_identity.destroy
          flash[:notice] = I18n.t("orcid_identity.preferences.destroy.success")

          redirect_back fallback_location: dashboard_profile_path(current_user)
        end

        protected

          def permitted_preference_params
            params.require(:orcid_identity).permit(:work_sync_preference, profile_sync_preference: {})
          end

          def request_authorization
            data = {
              client_id: Site.instance.account.settings["orcid_client_id"],
              client_secret: Site.instance.account.settings["orcid_client_secret"],
              grant_type: "authorization_code",
              code: code
            }

            @authorization_response = Faraday.post(helpers.orcid_token_uri, data.to_query, "Accept" => "application/json")
          end

          def authorization_success?
            @authorization_response.success?
          end

          def authorization_body
            JSON.parse(@authorization_response.body)
          end

          def code
            params.require(:code)
          end
      end
    end
  end
end
