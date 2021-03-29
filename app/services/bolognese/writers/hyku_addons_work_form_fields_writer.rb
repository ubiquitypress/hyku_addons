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
      DOI_REGEX = /10.\d{4,9}\/[-._;()\/:A-Z0-9]+/
      ROR_QUERY_URL = "https://api.ror.org/organizations?query="

      def hyku_addons_work_form_fields
        {
          "identifier" => Array(identifiers).select { |id| id["identifierType"] != "DOI" }.pluck("identifier"),
          "doi" => Array(doi),
          "title" => titles&.pluck("title"),
          "creator" => write_involved("creators"),
          "contributor" => write_involved("contributors"),
          "funder" => write_funders,
          "publisher" => Array(publisher),
          "date_created" => write_date("date_created", collect_date("Issued")),
          "date_updated" => write_date("date_updated", collect_date("Updated")),
          "date_published" => write_date_published,
          "abstract" => write_descriptions,
          "keyword" => subjects&.pluck("subject")
        }
      end

      # NOTE:
      # This is here until its fixed upstream
      #
      # Some DOIs (10.7554/eLife.67932, 10.7554/eLife.65703) have namespaced funder keys, which causes
      # them not to be properly extracted inside of the crossref_reader:
      # https://github.com/datacite/bolognese/blob/master/lib/bolognese/readers/crossref_reader.rb#L66
      #
      # I've tried to overwrite as little as possible and use `super` instead of including the whole method
      def get_crossref(id: nil, **options)
        return { "string" => nil, "state" => "not_found" } unless id.present?

        string = super.dig("string")

        string = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks).remove_namespaces!.to_s if string.present?

        { "string" => string }
      end

      protected

        # NOTE:
        # This is here until its fixed upstream
        #
        # The `(5.+)` seems to invalidate valid funder DOIs
        def validate_funder_doi(doi)
          regex = /\A(?:(http|https):\/(\/)?(dx\.)?(doi.org|handle.test.datacite.org)\/)?(doi:)?(10\.13039\/)?(.+)\z/
          doi = Array(regex.match(doi)).last

          return unless doi.present?

          # remove non-printing whitespace and downcase
          doi.delete("\u200B").downcase
          "https://doi.org/10.13039/#{doi}"
        end

        def write_funders
          funding_references.map do |funder|
            funder.transform_keys!(&:underscore)

            # TODO: Need to get the award name from the number here
            funder["funder_award"] = Array.wrap(funder.delete("award_number"))

            if (doi = funder["funder_identifier"]&.match(DOI_REGEX)).present?
              # Ensure we only ever use the doi_id and not the full URL
              funder["funder_doi"] = doi[0]

              data = get_funder_ror(funder["funder_doi"])
              data.dig("external_ids")&.each do |type, values|
                funder["funder_#{type.downcase}"] = values["preferred"] || values["all"].first
              end

              funder["funder_ror"] = data.dig("id")
            end

            funder
          end
        end

        def write_involved(type)
          key = type.to_s.singularize

          meta.dig(type).map do |item|
            item.transform_keys! { |k| "#{key}_#{k.underscore}" }

            # Individual name identifiers will require specific tranformations as required
            item["#{key}_name_identifiers"]&.each_with_object(item) do |hash, identifier|
              identifier["#{key}_#{hash['nameIdentifierScheme'].downcase}"] = hash["nameIdentifier"]
            end

            # Incase edge cases don't provide a full set of name values, but should have: 10.7925/drs1.duchas_5019334
            item["#{key}_family_name"], item["#{key}_given_name"] = item["#{key}_name"].split(", ") if item["#{key}_name"]&.match?(/,/) && item["#{key}_given_name"].blank?

            item
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

        # Always returns a hash
        def get_funder_ror(funder_doi)
          # doi should be similar to "10.13039/501100000267" however we only want the second segment
          response = Faraday.get("#{ROR_QUERY_URL}#{funder_doi.split('/').last}")

          return {} unless response.success?

          # `body.items` is an array of hashes - but we only need the first one
          JSON.parse(response.body)&.dig("items")&.first || {}
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
