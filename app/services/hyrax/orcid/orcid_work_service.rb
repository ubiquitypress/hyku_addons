# frozen_string_literal: true

# This class is the meat of the publishing/unpublishing works to/from orcid.
module Hyrax
  module Orcid
    class OrcidWorkService
      include Hyrax::Orcid::UrlHelper
      include Hyrax::Orcid::WorkHelper

      def initialize(work, identity)
        @work = work
        @identity = identity
      end

      def publish
        request_method = previously_uploaded? ? :put : :post
        @response = Faraday.send(request_method, request_url, xml, headers)

        update_identity if @response.success?
      end

      def unpublish
        @response = Faraday.send(:delete, request_url, nil, headers)

        if @response.success?
          notify_unpublished
          orcid_work.destroy
        end
      end

      protected

        def xml
          input = @work.attributes.merge(has_model: @work.has_model.first).to_json
          meta = Bolognese::Readers::GenericWorkReader.new(input: input, from: "work")

          # TODO: figure out how to get the correct types here
          # TODO: try and think of a better way to get the put_code into the xml writer
          meta.orcid_xml("other", orcid_work.put_code)
        end

        def request_url
          orcid_api_uri(@identity.orcid_id, :work, orcid_work.put_code)
        end

        def headers
          {
            "authorization" => "Bearer #{@identity.access_token}",
            "Content-Type" => "application/vnd.orcid+xml"
          }
        end

        def notify_unpublished
          return if primary_user?

          subject = I18n.t("orcid_identity.unpublish.notification.subject", depositor_description: depositor_description)
          params = {
            depositor_profile: orcid_profile_uri(depositor.orcid_identity.orcid_id),
            depositor_description: depositor_description,
            work_title: @work.title.first
          }
          body = I18n.t("orcid_identity.unpublish.notification.body", params)

          depositor.send_message(@identity.user, body, subject)
        end

        def update_identity
          put_code = @response.headers.dig("location")&.split("/")&.last
          orcid_work.update(work_uuid: @work.id, put_code: put_code)
        end
    end
  end
end
