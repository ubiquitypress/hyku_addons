# frozen_string_literal: true

module Hyrax
  module Orcid
    class SyncAllStrategy
      include Hyrax::Orcid::UrlHelper

      def initialize(work, identity)
        @work = work
        @identity = identity
      end

      def perform
        # Hyrax::Orcid::SyncAllStrategy.new(@work, @identity).perform
        @response = Faraday.send(request_method, request_url, xml, headers)

        update_identity if @response.success?
      end

      protected

        def xml
          input = @work.attributes.merge(has_model: @work.has_model.first).to_json
          meta = Bolognese::Readers::GenericWorkReader.new(input: input, from: "work")

          # TODO: figure out how to get the correct types here
          # TODO: try and think of a better way to get the put_code into the xml writer
          meta.orcid_xml("other", orcid_work.put_code)
        end

        def request_method
          previously_uploaded? ? :put : :post
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

      private

        def update_identity
          put_code = @response.headers.dig("location")&.split("/")&.last
          orcid_work.update(work_uuid: @work.id, put_code: put_code)
        end

        def previously_uploaded?
          orcid_work.put_code.present?
        end

        def orcid_work
          @_orcid_work ||= @identity.orcid_works.where(work_uuid: @work.id).first_or_initialize
        end
    end
  end
end
