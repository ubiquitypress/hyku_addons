# frozen_string_literal: true

# NOTE:
# Add new fields here that should be available to prefill the work forms.
# You must also add the logic to the PrefillWorkFormViaDOI JS class.
#
# The processed JSON can be access via a JSON request:
# # http://YOUR_TENANT.lvh.me:3000/doi/autofill.xml?curation_concern=generic_work&doi=YOUR_DOI
#
# To create fixtures for specs, the the unprocessed XML can be accessed via an XML request.
# NOTE: Copy the raw source, not the HTML output:
# http://YOUR_TENANT.lvh.me:3000/doi/autofill.xml?curation_concern=generic_work&doi=YOUR_DOI

# rubocop:disable Metrics/ModuleLength
module Bolognese
  module Writers
    module HykuAddonsWorkFormFieldsWriter
      include HykuAddons::WorkFormNameable

      UNAVAILABLE_LABEL = ":(unav)"
      DATE_FORMAT = "%Y-%-m-%-d"
      DOI_REGEX = /10.\d{4,9}\/[-._;()\/:A-Z0-9]+/
      ROR_QUERY_URL = "https://api.ror.org/organizations?query="
      AFTER_ACTIONS = %i[process_editor_contributors! ensure_creator_from_editor!].freeze

      def hyku_addons_work_form_fields(curation_concern: "generic_work")
        @curation_concern = curation_concern

        @form_data = process_work_type_terms

        AFTER_ACTIONS.map { |action| send(action) }

        # Work through each of the work types fields to create the data hash
        @form_data.compact.reject { |_key, value| value.blank? }
      end

      protected

        def write_doi
          Array(doi)
        end

        def write_title
          titles&.pluck("title")
        end

        def write_creator
          write_involved("creators")
        end

        def write_contributor
          write_involved("contributors")
        end

        def write_editor
          write_involved("contributors").select { |cont| cont["contributor_contributor_type"] == "Editor" }
        end

        def write_publisher
          Array(publisher)
        end

        def write_keyword
          subjects&.pluck("subject")
        end

        def write_language
          Array(language)
        end

        def write_issn
          [identifier_by_type(:container, "ISSN")].compact
        end

        def write_isbn
          [identifier_by_type(:identifiers, "ISBN")].compact
        end

        def write_license
          urls = rights_list&.pluck("rightsUri")&.uniq&.compact

          return if urls.blank?

          # Licences coming from the XML seem to have `legalcode` appended to them:
          # I.e. https://creativecommons.org/licenses/by/4.0/legalcode
          # This will not match any of the values in the select menu so this is a fix for now
          urls.map { |url| url.gsub("legalcode", "") }
        end

        # There will be differences in how the url's are structured within the data (10.7925/drs1.duchas_5019334).
        # Because of this they may be missing, so we should fallback to the DOI.
        def write_official_link
          Array(url || "https//doi.org/#{doi}")
        end

        def write_journal_title
          return unless container.present? && container.dig("type") == "Journal"

          [container&.dig("title")].compact
        end

        def write_volume
          container&.dig("volume")
        end

        def write_abstract
          return nil if descriptions.blank?

          descriptions.pluck("description")&.map { |d| Array(d).join("\n") }
        end

        def write_date_published
          publication_date = collect_date("Issued") || publication_year

          hash_from_date("date_published", Array(date_from_string(publication_date)))
        end

        def write_funder
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

        # Book chapters have a distinct Book Title field for their parent books title
        def write_book_title
          [container&.dig("title")].compact
        end

        # The following is required for when first and last pages are entered/missing
        # f: 9
        # l: 27
        # res: 9-27
        # =======
        # f: 9
        # l:
        # res: 9
        # =======
        # f:
        # l: 27
        # res: 27
        def write_pagination
          return unless container.present?

          pagination = [container.dig("firstPage"), "-", container.dig("lastPage")].compact

          if pagination.size == 3
            [pagination.join("")]

          # If we don't have a full array, remove the hyphen and return what we have
          else
            pagination.compact.reject { |a| a == "-" }
          end
        end

      private

        def process_work_type_terms
          work_type_terms.each_with_object({}) do |term, data|
            method_name = "write_#{term}"

            data[term.to_s] = respond_to?(method_name, true) ? send(method_name) : nil
          end
        end

        def write_involved(type)
          key = type.to_s.singularize

          meta.dig(type)&.map do |item|
            # transform but don't change original or each time method is run it prepends the key
            trans = item.transform_keys { |k| "#{key}_#{k.underscore}" }

            # Individual name identifiers will require specific tranformations as required
            trans["#{key}_name_identifiers"]&.each_with_object(trans) do |hash, identifier|
              identifier["#{key}_#{hash['nameIdentifierScheme'].downcase}"] = hash["nameIdentifier"]
            end

            # We need to ensure that the field is named properly if we have an organisation if its not blank
            if trans.dig("#{key}_name_type") == "Organizational" && trans["#{key}_name"] != UNAVAILABLE_LABEL
              trans["#{key}_organization_name"] = trans.delete("#{key}_name")

            # Incase edge cases don't provide a full set of name values, but should have: 10.7925/drs1.duchas_5019334
            elsif trans["#{key}_name"]&.match?(/,/) && trans["#{key}_given_name"].blank?
              trans["#{key}_family_name"], trans["#{key}_given_name"] = trans["#{key}_name"].split(", ")
            end

            trans
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

        # Dip into a data continer and check for a specific key, returning the value is present
        # bucket would normally be `identifiers` or `container`
        def identifier_by_type(bucket, type)
          Array.wrap(send(bucket))&.find { |id| id["identifierType"] == type }&.dig("identifier")
        end

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

        # Required for WorkFormNameable to function correctly
        def meta_model
          @curation_concern.classify
        end

        # If we have no creator, but we do have editors, then we need to transform the editor contributors to creators
        def ensure_creator_from_editor!
          return unless @form_data["creator"].first&.dig("creator_name") == UNAVAILABLE_LABEL
          return unless @form_data["editor"].present?

          @form_data["creator"] = @form_data.delete("editor").map! do |cont|
            cont.transform_keys! { |key| key.gsub("contributor", "creator") }
          end
        end

        def process_editor_contributors!
          editors = proc { |item| item["contributor_contributor_type"] == "Editor" }

          # If we do not have editors, they might be missing from the fields for this work type.
          # This is so that we can reliably use them later on in the callbacks chain
          @form_data["editor"] = @form_data["contributor"].select(&editors) if @form_data["editor"].blank? && @form_data["contributor"].any?(&editors)

          # If we have editors, then they are formed from contributor data, which can be removed to avoid duplication
          @form_data["contributor"].reject!(&editors)
        end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
