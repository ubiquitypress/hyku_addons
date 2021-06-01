# frozen_string_literal: true

module Hyrax
  module OrcidHelper
    ORCID_API_VERSION = "v3.0"
    ORCID_REGEX = %r{
      (?:(http|https):\/\/
      (?:www\.(?:sandbox\.)?)?orcid\.org\/)?
      (\d{4}[[:space:]-]\d{4}[[:space:]-]\d{4}[[:space:]-]\d{3}[0-9X]+)
    }x


    def orcid_profile_uri(profile_id)
      "https://#{orcid_domain}/#{profile_id}"
    end

    def orcid_authorize_uri
      params = {
        client_id: Site.instance.account.settings["orcid_client_id"],
        scope: "/activities/update%20/read-limited",
        response_type: "code",
        redirect_uri: Site.instance.account.settings["orcid_redirect"]
      }

      "https://#{orcid_domain}/oauth/authorize?#{params.to_query}"
    end

    def orcid_token_uri
      "https://#{orcid_domain}/oauth/token"
    end

    def orcid_api_uri(orcid_id, endpoint)
      "https://api.#{orcid_domain}/#{ORCID_API_VERSION}/#{orcid_id}/#{endpoint}"
    end

    def validate_orcid(orcid)
      orcid = orcid.match(ORCID_REGEX)

      orcid.to_s.gsub(/[[:space:]]/, "-") if orcid.present?
    end

    protected

      def orcid_domain
        "#{'sandbox.' unless Rails.env.production?}orcid.org"
      end
  end
end
