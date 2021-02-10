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
      def self.special_fields
        %i[json_fields date_fields]
      end

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
            curation_concern: params[:curation_concern]
          }.to_json
        end

        def formatted_work
          meta = reader_class.new(input: doi)

          raise Hyrax::DOI::NotFoundError, "DOI (#{doi}) could not be found." if meta.blank? || meta.doi.blank?

          # We need a hash to work with
          @work = JSON.parse(meta.hyrax_work.to_json)

          process_special_fields!

          @work
        end

        def model_class
          curation_concern.constantize
        end

        def reader_class
          "Bolognese::Readers::#{curation_concern}Reader".constantize
        rescue NameError
          Bolognese::Readers::GenericWorkReader
        end

        def form_class
          "Hyrax::#{curation_concern}Form".constantize
        end

        def curation_concern
          params[:curation_concern].camelize
        end

        def doi
          params.require(:doi)
        end

      private

        def process_special_fields!
          self.class.special_fields.each do |field|
            method_name = "process_#{field}!".to_sym

            send(method_name) if respond_to?(method_name, true)
          end
        end

        def process_json_fields!
          # Only iterate over the minimum necessary fields
          fields = @work.slice(*model_class.json_fields.map(&:to_s))

          fields.each do |key, value|
            # Convert the array field fields into hash keys with nil values
            hash = Hash[form_class.send("#{key}_fields").dig(key.to_sym).zip]

            # NOTE:
            # This is ugly, but i'm not sure of a better way to do it
            if hash.keys.grep(%r{family_name}) && (name = value.first&.split(', '))
              hash["#{key}_family_name".to_sym] = name[0]
              hash["#{key}_given_name".to_sym] = name[1]
            end

            @work[key] = hash
          end
        end

        def process_date_fields!
          segments = %i[year month day]
          fields = @work.slice(*model_class.date_fields.map(&:to_s))

          fields.each do |key, value|
            hash = Hash[form_class.send("#{key}_fields").dig(key.to_sym).zip]

            next unless (date = Date.edtf(value.first))

            # Use the segment to call the required method on the date and assign to the correct json date field
            segments.each { |segment, _index| hash["#{key}_#{segment}".to_sym] = date.send(segment) }

            @work[key] = hash
          end
        end
    end
  end
end
