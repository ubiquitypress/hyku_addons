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

# rubocop:disable Metrics/ModuleLength
module Bolognese
  module Writers
    module HykuAddonsWorkFormFieldsWriter
      DATE_FORMAT = "%Y-%-m-%-d"
      DOI_REGEX = /10.\d{4,9}\/[-._;()\/:A-Z0-9]+/
      ROR_QUERY_URL = "https://api.ror.org/organizations?query="

      # rubocop:disable Metrics/MethodLength
      def hyku_addons_work_form_fields
        {
          "identifier" => write_identifier,
          "doi" => Array(doi),
          "title" => titles&.pluck("title"),
          "creator" => write_involved("creators"),
          "contributor" => write_involved("contributors"),
          "funder" => write_funders,
          "publisher" => Array(publisher),
          "abstract" => write_descriptions,
          "keyword" => subjects&.pluck("subject"),
          "official_link" => write_official_link,
          "language" => Array(language),
          "volume" => write_volume,
          "date_published" => write_date_published,

          # FIXME
          "license" => rights_list&.pluck("rights")&.uniq,
          "issn" => write_issn
        }.compact.reject { |_key, value| value.blank? }
      end
      # rubocop:enable Metrics/MethodLength

      # NOTE:
      # This is here until its fixed upstream: https://github.com/datacite/bolognese/issues/109
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
        # This is here until its fixed upstream: https://github.com/datacite/bolognese/issues/108
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

        # There will be differences in how the url's are structured within the data (10.7925/drs1.duchas_5019334).
        # Because of this they may be missing, so we should fallback to the DOI.
        def write_official_link
          Array(url || "https//doi.org/#{doi}")
        end

        def write_volume
          container&.dig("volume")
        end

        def write_identifier
          Array(identifiers).select { |id| id["identifierType"] != "DOI" }.pluck("identifier")
        end

        def write_issn
          return unless container.present?

          container.dig("indentifierType") == "ISSN" ? container.dig("indentifier") : nil
        end

        def write_funders
          grouped_funders&.map do |funder|
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

          meta.dig(type)&.map do |item|
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

          descriptions.pluck("description")&.map { |d| Array(d).join("\n") }
        end

        def write_date_published
          publication_date = collect_date("Issued") || publication_year

          hash_from_date("date_published", Array(date_from_string(publication_date)))
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

        #
        # Date values are formatted without number padding in the form
        def date_from_string(date_string)
          return unless date_string.present?

          Date.edtf(date_string)
        end

        # Return a an array containing a date hash formatted as the work forms require
        def hash_from_date(field, dates)
          dates.map do |date|
            {
              "#{field}_year" => date.year,
              "#{field}_month" => date.month,
              "#{field}_day" => date.day
            }
          end
        end

        # `dates` is an array of hashes containing a string date and named dateType
        def collect_date(type)
          dates.find { |hash| hash["dateType"] == type }&.dig("date")
        end

        # Group the funders by their name, as we might not have a unique DOI for them.
        # This is a big of a sledge hammer approach, but I believe it'll work for now.
        def grouped_funders
          return unless funding_references.present?

          funding_references.group_by { |funder| funder["funderName"] }.map do |_name, group|
            funder = group.first
            funder["awardNumber"] = group.pluck("awardNumber").compact

            funder
          end
        end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
