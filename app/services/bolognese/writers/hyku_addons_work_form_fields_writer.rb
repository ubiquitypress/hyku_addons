# frozen_string_literal: true

# NOTE:
# Add new fields here that should be available to prefill the work forms.
# You must also add the logic to the PrefillWorkFormViaDOI JS class.
module Bolognese
  module Writers
    module HykuAddonsWorkFormFieldsWriter
      DATE_FORMAT = "%Y-%-m-%-d"

      def hyku_addons_work_form_fields
        {
          'identifier' => Array(identifiers).select { |id| id["identifierType"] != "DOI" }.pluck("identifier"),
          'doi' => Array(doi),
          'title' => titles&.pluck("title"),
          'creator' => write_involved("creators"),
          'contributor' => write_involved("contributors"),
          'publisher' => Array(publisher),
          'date_created' => write_date("date_created", collect_date("Issued")),
          'date_updated' => write_date("date_updated", collect_date("Updated")),
          "date_published" => write_date_published,
          'description' => write_descriptions,
          'keyword' => subjects&.pluck("subject")
        }
      end

      protected

        def write_date_published
          write_date("date_published", Array(format_date(publication_year)))
        end

        def write_date(field, dates)
          dates.map do |date|
            {
              "#{field}_year" => date.year,
              "#{field}_month" => date.month,
              "#{field}_day" => date.day
            }
          end
        end

        def write_involved(type)
          # Convert the keys to singular and underscored, to match field names
          meta.dig(type).map { |hash| hash.map { |k, v| ["#{type.singularize}_#{k.underscore}", v] }.to_h }
        end

        def write_descriptions
          return nil if descriptions.blank?

          descriptions.pluck("description").map { |d| Array(d).join("\n") }
        end

      private

        # `dates` is an array of hashes containing all date information
        def collect_date(type)
          Array(format_date(dates.find { |hash| hash["dateType"] == type }&.dig("date")))
        end

        # Date values are formatted without number padding in the form
        def format_date(date_string)
          return unless date_string.present?

          Date.edtf(date_string)
        end
    end
  end
end
