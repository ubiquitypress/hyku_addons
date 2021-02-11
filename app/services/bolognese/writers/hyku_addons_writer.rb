module Bolognese
  module Writers
    module HykuAddonsWriter
      def hyku_addons_work(work_model:)
        # Set this so it can be accessed universally
        types["workModel"] = work_model

        @hyku_addons_work = {
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

        process_json_fields!
        process_date_fields!

        # NOTE:
        # We cannot return a reader instance as the JSON/Date fields cause an ActiveTriples::Relation::ValueError error
        @hyku_addons_work
      end

      private

        def build_hyrax_work_doi
          Array(doi&.sub('https://doi.org/', ''))
        end

        def build_hyrax_work_description
          return nil if descriptions.blank?
          descriptions.pluck("description").map { |d| Array(d).join("\n") }
        end

        def work_model
          types["workModel"].camelize
        end

        def form_class
          "Hyrax::#{work_model}Form".constantize
        end

        def work_class
          work_model&.safe_constantize
        end

        def process_json_fields!
          # Only iterate over the minimum necessary fields
          fields = @hyku_addons_work.slice(*work_class.json_fields.map(&:to_s))

          fields.each do |key, value|
            # Convert the array field fields into hash keys with nil values
            hash = Hash[form_class.send("#{key}_fields").dig(key.to_sym).zip]

            # NOTE:
            # This is ugly, but i'm not sure of a better way to do it
            if hash.keys.grep(%r{family_name}) && (name = value.first&.split(', '))
              hash["#{key}_family_name".to_sym] = name[0]
              hash["#{key}_given_name".to_sym] = name[1]
            end

            @hyku_addons_work[key] = hash
          end
        end

        def process_date_fields!
          segments = %i[year month day]
          fields = @hyku_addons_work.slice(*work_class.date_fields.map(&:to_s))

          fields.each do |key, value|
            hash = Hash[form_class.send("#{key}_fields").dig(key.to_sym).zip]

            next unless (date = Date.edtf(value.first))

            # Use the segment to call the required method on the date and assign to the correct json date field
            segments.each { |segment, _index| hash["#{key}_#{segment}".to_sym] = date.send(segment) }

            @hyku_addons_work[key] = hash
          end
        end
    end
  end
end

