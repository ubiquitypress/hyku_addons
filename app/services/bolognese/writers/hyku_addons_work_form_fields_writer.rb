# frozen_string_literal: true

# NOTE:
# Add new fields here that should be available to prefill the work forms.
# You must also add the logic to the PrefillWorkFormViaDOI JS class.
#
# Raw output from this class can be accessed via - Copy the raw source, not the HTML output:
# http://YOUR_TENANT.lvh.me:3000/doi/autofill?curation_concern=generic_work&doi=YOUR_DOI
#
# E.g
# http://repo.lvh.me:3000/doi/autofill?curation_concern=generic_work&doi=10.7554/elife.63646
module Bolognese
  module Writers
    module HykuAddonsWorkFormFieldsWriter
      DATE_FORMAT = "%Y-%-m-%-d"

      def hyku_addons_work_form_fields
        {
          "identifier" => Array(identifiers).select { |id| id["identifierType"] != "DOI" }.pluck("identifier"),
          "doi" => Array(doi),
          "title" => titles&.pluck("title"),
          "creator" => write_involved("creators"),
          "contributor" => write_involved("contributors"),
          "publisher" => Array(publisher),
          "date_created" => write_date("date_created", collect_date("Issued")),
          "date_updated" => write_date("date_updated", collect_date("Updated")),
          "date_published" => write_date_published,
          "abstract" => write_descriptions,
          "keyword" => subjects&.pluck("subject")
        }
      end

      protected

        def write_involved(type)
          type_name = type.to_s.singularize

          meta.dig(type).map do |involved|
            involved.transform_keys! { |key| "#{type_name}_#{key.underscore}" }

            # Individual name identifiers will require specific tranformations as required
            involved["#{type_name}_name_identifiers"]&.each_with_object(involved) do |hash, involved|
              involved["#{type_name}_#{hash['nameIdentifierScheme'].downcase}"] = hash["nameIdentifier"]
            end

            # Incase edge cases don't provide a full set of name values, but should have: 10.7925/drs1.duchas_5019334
            if involved["#{type_name}_name"]&.match?(/,/) && involved["#{type_name}_given_name"].blank?
              involved["#{type_name}_family_name"], involved["#{type_name}_given_name"] = involved["#{type_name}_name"].split(", ")
            end

            involved
          end
        end

        def write_descriptions
          return nil if descriptions.blank?

          descriptions.pluck("description").map { |d| Array(d).join("\n") }
        end

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
