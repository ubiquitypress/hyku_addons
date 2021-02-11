# frozen_string_literal: true
# TODO: Why is this required, or we see NotFoundError class not found
module Hyrax
  module DOI
    class Error < ::StandardError; end
    class NotFoundError < Hyrax::DOI::Error; end
  end
end

module HykuAddons
  module DOIControllerBehavior
    extend ActiveSupport::Concern

    included do
      def autofill
        respond_to do |format|
          format.js { render json: json_response, status: :ok }

          # NOTE: This is temporary, just so we have a URL to debug
          format.html { render json: json_response, status: :ok }
        end

      rescue ::Hyrax::DOI::NotFoundError => e
        respond_to do |format|
          format.js { render plain: e.message, status: :internal_server_error }
        end
      end

      protected

        def json_response
          {
            data: formatted_work,
            curation_concern: curation_concern
          }.to_json
        end

        def formatted_work
          # Download the requested DOI response
          input = reader_class.new(input: doi)

          # Use that response to build the object as we would expect it
          meta = reader_class.new(input: input.string)

          raise Hyrax::DOI::NotFoundError, "DOI (#{doi}) could not be found." if meta.blank? || meta.doi.blank?

          meta.hyku_addons_work(work_model: curation_concern)
        end

        def reader_class
          "Bolognese::Readers::#{curation_concern.camelize}Reader".constantize
        rescue NameError
          Bolognese::Readers::GenericWorkReader
        end

        def curation_concern
          params.require(:curation_concern)
        end

        def doi
          params.require(:doi)
        end
    end
  end
end
