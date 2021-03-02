# frozen_string_literal: true
require 'hyrax/doi/errors'

module HykuAddons
  module DOIControllerBehavior
    extend ActiveSupport::Concern
    included do
      def autofill
        respond_to do |format|
          # TODO: Make this respond to json instead of js
          format.js { render json: json_response, status: :ok }

          # NOTE: This is temporary, just so we have a URL to debug
          # format.html { render xml: raw_response.string, status: :ok }
          format.html { render json: json_response, status: :ok }
        end

      rescue ::Hyrax::DOI::NotFoundError => e
        respond_to do |format|
          format.js { render plain: e.message, status: :internal_server_error }
        end
      end

      protected

        def json_response
          { data: formatted_work, curation_concern: curation_concern }.to_json
        end

        def formatted_work
          meta = Bolognese::Metadata.new(input: doi)

          raise ::Hyrax::DOI::NotFoundError, "DOI (#{doi}) could not be found." if meta.blank? || meta.doi.blank?

          meta.hyku_addons_work_form_fields
        end

        def curation_concern
          params.require(:curation_concern)
        end

        def doi
          params.require(:doi)
        end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
