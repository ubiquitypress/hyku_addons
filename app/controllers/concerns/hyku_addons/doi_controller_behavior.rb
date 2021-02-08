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
          format.html { render js: datacite_json_from_doi(params[:doi]), status: :ok }
        end
      rescue ::Hyrax::DOI::NotFoundError => e
        respond_to do |format|
          format.js { render plain: e.message, status: :internal_server_error }
        end
      end

      def datacite_json_from_doi(doi)
        meta = Bolognese::Metadata.new(input: doi)

        raise Hyrax::DOI::NotFoundError, "DOI (#{doi}) could not be found." if meta.blank? || meta.doi.blank?

        meta.datacite_json
      end
    end
  end
end
