# frozen_string_literal: true
require 'hyrax/doi/errors'

module HykuAddons
  module DOIControllerBehavior
    extend ActiveSupport::Concern

    included do
      def autofill
        respond_to do |format|
          # http://repo.hyku.docker/doi/autofill.json?curation_concern=generic_work&doi=10.7554/elife.63646
          format.json { render json: json_response, status: :ok }

          # Allow easier debugging of DOIs in production
          if current_user&.has_role?(:admin)
            # NOTE: Use this to see the raw XML returned, useful for creating fixtures for specs,
            # copy the raw sauce, NOT the html rendered output or you will see errors:
            #
            # http://repo.hyku.docker/doi/autofill.xml?curation_concern=generic_work&doi=10.7554/elife.63646
            format.xml { render xml: raw_response.string, status: :ok }
          end
        end

      rescue ::Hyrax::DOI::NotFoundError => e
        respond_to do |format|
          format.json { render plain: e.message, status: :internal_server_error }
        end
      end
    end

    protected

      def json_response
        { data: formatted_work, curation_concern: curation_concern }.to_json
      end

      def formatted_work
        raw_response.hyku_addons_work_form_fields(curation_concern: curation_concern)
      end

      def raw_response
        response = Bolognese::Metadata.new(input: doi)

        return response if response.string.present? && response.meta.present?

        raise ::Hyrax::DOI::NotFoundError, "DOI (#{doi}) could not be found."
      end

      def curation_concern
        params.require(:curation_concern)
      end

      def doi
        params.require(:doi)
      end
  end
end
