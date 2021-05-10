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

      # This overrides the default `read_crossref` as they do not deal with book chapters very well, and are super
      # unresponsive on Github issues/pr's. Remove this method if/when PR merged into master.
      #
      # PR: https://github.com/datacite/bolognese/pull/115
      #
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/AbcSize
      def read_crossref(string: nil, **options)
        read_options = ActiveSupport::HashWithIndifferentAccess.new(options.except(:doi, :id, :url, :sandbox, :validate, :ra))

        if string.present?
          m = Maremma.from_xml(string).dig("crossref_result", "query_result", "body", "query", "doi_record") || {}
          meta = m.dig("doi_record", "crossref", "error").nil? ? m : {}

          # query contains information from outside metadata schema, e.g. publisher name
          query = Maremma.from_xml(string).dig("crossref_result", "query_result", "body", "query") || {}
        else
          meta = {}
          query = {}
        end

        # model should be one of book, conference, database, dissertation, journal, peer_review, posted_content,
        # report_paper, sa_component, standard
        model = meta.dig("crossref").to_h.keys.last

        resource_type = nil
        bibliographic_metadata = {}
        program_metadata = {}
        journal_metadata = nil
        journal_issue = {}
        journal_metadata = nil
        publisher = query.dig("crm_item", 0)
        publisher = nil unless publisher.is_a?(String)

        case model
        when "book"
          book_metadata = meta.dig("crossref", "book", "book_metadata")
          book_series_metadata = meta.dig("crossref", "book", "book_series_metadata")
          book_set_metadata = meta.dig("crossref", "book", "book_set_metadata")
          bibliographic_metadata = meta.dig("crossref", "book", "content_item") || book_metadata || book_series_metadata || book_set_metadata
          resource_type = bibliographic_metadata.fetch("component_type", nil) ? "book-" + bibliographic_metadata.fetch("component_type") : "book"
          # publisher = if book_metadata.present?
          #               book_metadata.dig("publisher", "publisher_name")
          #             elsif book_series_metadata.present?
          #               book_series_metadata.dig("publisher", "publisher_name")
          #             end
        when "conference"
          event_metadata = meta.dig("crossref", "conference", "event_metadata") || {}
          bibliographic_metadata = meta.dig("crossref", "conference", "conference_paper").to_h
        when "journal"
          journal_metadata = meta.dig("crossref", "journal", "journal_metadata") || {}
          journal_issue = meta.dig("crossref", "journal", "journal_issue") || {}
          journal_article = meta.dig("crossref", "journal", "journal_article") || {}
          bibliographic_metadata = journal_article.presence || journal_issue.presence || journal_metadata
          program_metadata = bibliographic_metadata.dig("crossmark", "custom_metadata", "program") || bibliographic_metadata.dig("program")
          resource_type = if journal_article.present?
                              "journal_article"
                            elsif journal_issue.present?
                              "journal_issue"
                            else
                              "journal"
                            end
        when "posted_content"
          bibliographic_metadata = meta.dig("crossref", "posted_content").to_h
          publisher ||= bibliographic_metadata.dig("institution", "institution_name")
        when "sa_component"
          bibliographic_metadata = meta.dig("crossref", "sa_component", "component_list", "component").to_h
          related_identifier = Array.wrap(query.to_h["crm_item"]).find { |cr| cr["name"] == "relation" }
          journal_metadata = { "relatedIdentifier" => related_identifier.to_h.fetch("__content", nil) }
        when "database"
          bibliographic_metadata = meta.dig("crossref", "database", "dataset").to_h
          resource_type = "dataset"
        when "report_paper"
          bibliographic_metadata = meta.dig("crossref", "report_paper", "report_paper_metadata").to_h
          resource_type = "report"
        when "peer_review"
          bibliographic_metadata = meta.dig("crossref", "peer_review")
        when "dissertation"
          bibliographic_metadata = meta.dig("crossref", "dissertation")
        end

        resource_type = (resource_type || model).to_s.underscore.camelcase.presence
        schema_org = Bolognese::Utils::CR_TO_SO_TRANSLATIONS[resource_type] || "ScholarlyArticle"
        types = {
          "resourceTypeGeneral" => Bolognese::Utils::CR_TO_DC_TRANSLATIONS[resource_type],
          "resourceType" => resource_type,
          "schemaOrg" => schema_org,
          "citeproc" => Bolognese::Utils::CR_TO_CP_TRANSLATIONS[resource_type] || "article-journal",
          "bibtex" => Bolognese::Utils::CR_TO_BIB_TRANSLATIONS[resource_type] || "misc",
          "ris" => Bolognese::Utils::CR_TO_RIS_TRANSLATIONS[resource_type] || "JOUR"
        }.compact

        titles = if bibliographic_metadata.dig("titles").present?
                   Array.wrap(bibliographic_metadata.dig("titles")).map do |r|
                     if r.blank? || (r["title"].blank? && r["original_language_title"].blank?)
                       nil
                     elsif r["title"].is_a?(String)
                       { "title" => sanitize(r["title"]) }
                     elsif r["original_language_title"].present?
                       { "title" => sanitize(r.dig("original_language_title", "__content__")), "lang" => r.dig("original_language_title", "language") }
                     else
                       { "title" => sanitize(r.dig("title", "__content__")) }.compact
                     end
                   end.compact
                 else
                   [{ "title" => ":(unav)" }]
                 end

        date_published = crossref_date_published(bibliographic_metadata)
        if date_published.present?
          date_published = { "date" => date_published, "dateType" => "Issued" }
        else
          date_published = Array.wrap(query.to_h["crm_item"]).find { |cr| cr["name"] == "created" }
          date_published = { "date" => date_published.fetch("__content__", "")[0..9], "dateType" => "Issued" } if date_published.present?
        end
        date_updated = Array.wrap(query.to_h["crm_item"]).find { |cr| cr["name"] == "last-update" }
        date_updated = { "date" => date_updated.fetch("__content__", nil), "dateType" => "Updated" } if date_updated.present?

        date_registered = Array.wrap(query.to_h["crm_item"]).find { |cr| cr["name"] == "deposit-timestamp" }
        date_registered = get_datetime_from_time(date_registered.fetch("__content__", nil)) if date_registered.present?

        # check that date is valid iso8601 date
        date_published = nil unless Date.edtf(date_published.to_h["date"]).present?
        date_updated = nil unless Date.edtf(date_updated.to_h["date"]).present?

        dates = [date_published, date_updated].compact
        publication_year = date_published.to_h.fetch("date", "")[0..3].presence

        state = meta.present? || read_options.present? ? "findable" : "not_found"

        related_identifiers = Array.wrap(crossref_is_part_of(journal_metadata)) + Array.wrap(crossref_references(bibliographic_metadata))

        container = if journal_metadata.present?
                      issn = normalize_issn(journal_metadata.to_h.fetch("issn", nil))

                      { "type" => "Journal",
                        "identifier" => issn,
                        "identifierType" => issn.present? ? "ISSN" : nil,
                        "title" => parse_attributes(journal_metadata.to_h["full_title"]),
                        "volume" => parse_attributes(journal_issue.dig("journal_volume", "volume")),
                        "issue" => parse_attributes(journal_issue.dig("issue")),
                        "firstPage" => bibliographic_metadata.dig("pages", "first_page") || parse_attributes(journal_article.to_h.dig("publisher_item", "item_number"), first: true),
                        "lastPage" => bibliographic_metadata.dig("pages", "last_page") }.compact

                    # By using book_metadata, we can account for where resource_type is `BookChapter` and not assume its a whole book
                    elsif book_metadata.present?
                      identifiers = crossref_alternate_identifiers(book_metadata)

                      {
                        "type" => "Book",
                        "title" => book_metadata.dig("titles", "title"),
                        "firstPage" => bibliographic_metadata.dig("pages", "first_page"),
                        "lastPage" => bibliographic_metadata.dig("pages", "last_page"),
                        "identifiers" => identifiers,
                      }.compact

                    elsif book_series_metadata.to_h.fetch("series_metadata", nil).present?
                      issn = normalize_issn(book_series_metadata.dig("series_metadata", "issn"))

                      { "type" => "Book Series",
                        "identifier" => issn,
                        "identifierType" => issn.present? ? "ISSN" : nil,
                        "title" => book_series_metadata.dig("series_metadata", "titles", "title"),
                        "volume" => bibliographic_metadata.fetch("volume", nil) }.compact
                    end

        id = normalize_doi(options[:doi] || options[:id] || bibliographic_metadata.dig("doi_data", "doi"))

        # Let sections override this in case of alternative metadata structures, such as book chapters, which
        # have their meta inside `content_item`, but the main book indentifers inside of `book_metadata`
        identifiers ||= crossref_alternate_identifiers(bibliographic_metadata)

        { "id" => id,
          "types" => types,
          "doi" => doi_from_url(id),
          "url" => parse_attributes(bibliographic_metadata.dig("doi_data", "resource"), first: true),
          "titles" => titles,
          "identifiers" => identifiers,
          "creators" => crossref_people(bibliographic_metadata, "author"),
          "contributors" => crossref_people(bibliographic_metadata, "editor"),
          "funding_references" => crossref_funding_reference(program_metadata),
          "publisher" => publisher,
          "container" => container,
          "agency" => agency = options[:ra] || "crossref",
          "related_identifiers" => related_identifiers,
          "dates" => dates,
          "publication_year" => publication_year,
          "descriptions" => crossref_description(bibliographic_metadata),
          "rights_list" => crossref_license(program_metadata),
          "version_info" => nil,
          "subjects" => nil,
          "language" => nil,
          "sizes" => nil,
          "schema_version" => nil,
          "state" => state,
          "date_registered" => date_registered
        }.merge(read_options)
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize

      protected

        # NOTE:
        # This is here until its fixed upstream: https://github.com/datacite/bolognese/issues/108
        # PR: https://github.com/datacite/bolognese/pull/114
        #
        # The `(5.+)` seems to invalidate valid funder DOIs
        def validate_funder_doi(doi)
          regex = /\A(?:(http|https):\/(\/)?(dx\.)?(doi.org|handle.test.datacite.org)\/)?(doi:)?(10\.13039\/)?([1-9]\d+)\z/.match(doi)
          # Compact to ensure nil is not returned for valid DOI's without a funder prefix, i.e 501100001711
          doi = Array(regex).compact.last

          return if doi.blank?

          # remove non-printing whitespace and downcase
          doi.delete("\u200B").downcase
          "https://doi.org/10.13039/#{doi}"
        end

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
            transformed = item.transform_keys { |k| "#{key}_#{k.underscore}" }

            # Individual name identifiers will require specific tranformations as required
            transformed["#{key}_name_identifiers"]&.each_with_object(transformed) do |hash, identifier|
              identifier["#{key}_#{hash['nameIdentifierScheme'].downcase}"] = hash["nameIdentifier"]
            end

            # Incase edge cases don't provide a full set of name values, but should have: 10.7925/drs1.duchas_5019334
            if transformed["#{key}_name"]&.match?(/,/) && transformed["#{key}_given_name"].blank?
              transformed["#{key}_family_name"], transformed["#{key}_given_name"] = transformed["#{key}_name"].split(", ")
            end

            transformed
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

        # If we have editors, then they are formed from contributor data, which can be removed to avoid duplication
        def process_editor_contributors!
          return unless @form_data["editor"].present?

          @form_data["contributor"].reject! { |cont| cont["contributor_contributor_type"] == "Editor" }
        end

        # If we have no creator, but we do have editors, then we need to transform the editor contributors to creators
        def ensure_creator_from_editor!
          return unless @form_data.dig("creator").first&.dig("creator_name") == UNAVAILABLE_LABEL
          return unless @form_data.dig("editor").present?

          @form_data["creator"] = @form_data.delete("editor").map! do |cont|
            cont.transform_keys! { |key| key.gsub("contributor", "creator") }
          end
        end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
