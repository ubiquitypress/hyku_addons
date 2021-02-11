module Bolognese
  module Writers
    module GenericWorkWriter
      def self.special_fields
        %i[json_fields date_fields]
      end

      def generic_work
        attributes = {
          'identifier' => Array(identifiers).select { |id| id["identifierType"] != "DOI" }.pluck("identifier"),
          'doi' => build_hyrax_work_doi,
          'title' => titles&.pluck("title"),
          # FIXME: This may not roundtrip since datacite normalizes the creator name
          'creator' => creators&.pluck("name"),
          'contributor' => contributors&.pluck("name"),
          'publisher' => Array(publisher),
          'date_created' => Array(publication_year),
          'description' => build_hyrax_work_description,
          'keyword' => subjects&.pluck("subject")
        }
        hyrax_work_class = determine_hyrax_work_class
        # Only pass attributes that the work type knows about
        hyrax_work_class.new(attributes.slice(*hyrax_work_class.attribute_names))

        process_special_fields!
      end

      private
        def determine_hyrax_work_class
          # Need to check that the class `responds_to? :doi`?
          types["hyrax"]&.safe_constantize || build_hyrax_work_class
        end

        def build_hyrax_work_class
          Class.new(ActiveFedora::Base).tap do |c|
            c.include ::Hyrax::WorkBehavior
            c.include ::Hyrax::DOI::DOIBehavior
            # Put BasicMetadata include last since it finalizes the metadata schema
            c.include ::Hyrax::BasicMetadata
          end
        end

        def build_hyrax_work_doi
          Array(doi&.sub('https://doi.org/', ''))
        end

        def build_hyrax_work_description
          return nil if descriptions.blank?
          descriptions.pluck("description").map { |d| Array(d).join("\n") }
        end

        def curation_concern
          params.require(:curation_concern).camelize
        end

        def form_class
          "Hyrax::#{curation_concern}Form".constantize
        end

        def model_class
          curation_concern.constantize
        end

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

