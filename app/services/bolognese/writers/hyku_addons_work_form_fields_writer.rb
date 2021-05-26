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
      include Bolognese::Helpers::Dates
      include Bolognese::Helpers::Writers

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
      # rubocop:disable Lint/UselessAssignment
      # rubocop:disable Lint/EndAlignment
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
                        "identifiers" => identifiers
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
          "date_registered" => date_registered }.merge(read_options)
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Lint/UselessAssignment
      # rubocop:enable Lint/EndAlignment

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


      private

        def process_work_type_terms
          work_type_terms.each_with_object({}) do |term, data|
            method_name = "write_#{term}"

            data[term.to_s] = respond_to?(method_name, true) ? send(method_name) : nil
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
