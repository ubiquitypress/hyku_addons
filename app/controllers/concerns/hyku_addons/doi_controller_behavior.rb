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
          curation_concern: params[:curation_concern],
          fields: {
            json: curation_concern_class.json_fields,
            date: curation_concern_class.date_fields,
          }
        }.to_json
      end

      def formatted_work
        meta = Bolognese::Metadata.new(input: doi)

        raise Hyrax::DOI::NotFoundError, "DOI (#{doi}) could not be found." if meta.blank? || meta.doi.blank?

        meta.hyrax_work
      end

      def curation_concern_class
        params[:curation_concern].camelize.constantize
      end

      def doi
        params.require(:doi)
      end
    end
  end
end
