# frozen_string_literal: true
module Bolognese
  module Writers
    module HykuAddonsWriter
      def hyku_addons_work(work_model:)
        # Set this so it can be accessed universally
        types["workModel"] = work_model

        {
          'identifier' => Array(identifiers).select { |id| id["identifierType"] != "DOI" }.pluck("identifier"),
          'doi' => Array(doi),
          'title' => titles&.pluck("title"),
          # FIXME: This may not roundtrip since datacite normalizes the creator name
          'creator' => creators,
          'contributor' => contributors,
          'publisher' => Array(publisher),
          'date_created' => write_dates("Issued"),
          'date_updated' => write_dates("Updated"),
          "date_published" => Date.edtf(publication_year).strftime("%Y-%m-%d"),
          'description' => write_descriptions,
          'keyword' => subjects&.pluck("subject")
        }
      end

      protected

        def write_dates(type)
          Array(dates.find { |hash| hash["dateType"] == type }&.dig("date"))
        end

        def write_descriptions
          return nil if descriptions.blank?

          descriptions.pluck("description").map { |d| Array(d).join("\n") }
        end

        private

          def work_model
            types["workModel"].camelize
          end

          def form_class
            "Hyrax::#{work_model}Form".constantize
          end

          def work_class
            work_model&.safe_constantize
          end
    end
  end
end
