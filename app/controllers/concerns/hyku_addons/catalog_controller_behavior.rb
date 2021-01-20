# frozen_string_literal: true
module HykuAddons
  module CatalogControllerBehavior
    extend ActiveSupport::Concern

    included do
      configure_blacklight do |config|
        # Re-configure facet fields
        config.facet_fields = {}
        config.add_facet_field solr_name("resource_type", :facetable), label: "Resource Type", limit: 5
        config.add_facet_field "creator_display_ssim", label: "Creator", limit: 5
        config.add_facet_field solr_name("keyword", :facetable), limit: 5
        config.add_facet_field solr_name('member_of_collections', :symbol), limit: 5, label: 'Collections'
        config.add_facet_field solr_name("institution", :facetable), limit: 5, label: 'Institution'
        config.add_facet_field solr_name("language", :facetable), limit: 5, label: 'Language'
        config.add_facet_fields_to_solr_request!

        # Re-configure index fields
        config.index_fields = {}
        config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name', if: false
        config.add_index_field "creator_display_ssim", label: 'Creator', itemprop: 'creator', link_to_search: 'creator_display_ssim'
        config.add_index_field "contributor_display_ssim", label: 'Contributor', itemprop: 'contributor', link_to_search: 'contributor_display_ssim'
        config.add_index_field solr_name("institution", :stored_searchable), label: "Institution", if: false # FIXME: Only when in shared search
        config.add_index_field solr_name("date_published", :stored_searchable), label: "Date Published"
        config.add_index_field solr_name("date_created", :stored_searchable), itemprop: 'dateCreated'
        config.add_index_field solr_name("resource_type", :stored_searchable), label: "Resource Type"
        config.add_index_field solr_name("embargo_release_date", :stored_sortable, type: :date), label: "Embargo release date", helper_method: :human_readable_date
        config.add_index_field solr_name("lease_expiration_date", :stored_sortable, type: :date), label: "Lease expiration date", helper_method: :human_readable_date
        config.add_index_field solr_name("member_of_collections", :symbol), label: 'Collection', link_to_search: solr_name("member_of_collections", :symbol)

        # Re-configure show fields
        config.show_fields = {}
        # solr fields to be displayed in the show (single result) view
        #   The ordering of the field names is the order of the display
        config.add_show_field solr_name("title", :stored_searchable)
        config.add_show_field solr_name("alt_title", :stored_searchable)
        config.add_show_field solr_name("description", :stored_searchable)
        config.add_show_field solr_name("keyword", :stored_searchable)
        config.add_show_field solr_name("journal_title", :stored_searchable)
        config.add_show_field solr_name("alternative_journal_title", :stored_searchable)
        config.add_show_field solr_name("subject", :stored_searchable)
        config.add_show_field "creator_display_ssim"
        config.add_show_field solr_name("version", :stored_searchable)
        config.add_show_field solr_name("related_exhibition", :stored_searchable)
        config.add_show_field solr_name("related_exhibition_venue", :stored_searchable)
        config.add_show_field solr_name("media", :stored_searchable)
        config.add_show_field solr_name("duration", :stored_searchable)
        config.add_show_field solr_name("event_title", :stored_searchable)
        config.add_show_field solr_name("event_date", :stored_searchable)
        config.add_show_field solr_name("event_location", :stored_searchable)
        config.add_show_field solr_name("abstract", :stored_searchable)
        config.add_show_field solr_name("book_title", :stored_searchable)
        config.add_show_field solr_name("series_name", :stored_searchable)
        config.add_show_field solr_name("edition", :stored_searchable)
        config.add_show_field "contributor_display_ssim"
        config.add_show_field solr_name("publisher", :stored_searchable)
        config.add_show_field solr_name("place_of_publication", :stored_searchable)
        config.add_show_field solr_name("date_published", :stored_searchable)
        config.add_show_field solr_name("based_near_label", :stored_searchable)
        config.add_show_field solr_name("language", :stored_searchable)
        config.add_show_field solr_name("date_uploaded", :stored_searchable)
        config.add_show_field solr_name("date_modified", :stored_searchable)
        config.add_show_field solr_name("date_created", :stored_searchable)
        config.add_show_field solr_name("rights_statement", :stored_searchable)
        config.add_show_field solr_name("license", :stored_searchable)
        config.add_show_field solr_name("resource_type", :stored_searchable)
        config.add_show_field solr_name("format", :stored_searchable)
        config.add_show_field solr_name("identifier", :stored_searchable)
        config.add_show_field solr_name("doi", :stored_searchable)
        config.add_show_field solr_name("qualification_name", :stored_searchable)
        config.add_show_field solr_name("qualification_level", :stored_searchable)
        config.add_show_field solr_name("isbn", :stored_searchable)
        config.add_show_field solr_name("issn", :stored_searchable)
        config.add_show_field solr_name("eissn", :stored_searchable)
        config.add_show_field solr_name("current_he_institution", :stored_searchable)
        config.add_show_field solr_name('extent', :stored_searchable)
        config.add_show_field solr_name("institution", :stored_searchable)
        config.add_show_field solr_name("org_unit", :stored_searchable)
        config.add_show_field solr_name("refereed", :stored_searchable)
        config.add_show_field solr_name("funder", :stored_searchable)
        config.add_show_field solr_name("fndr_project_ref", :stored_searchable)
        config.add_show_field solr_name("add_info", :stored_searchable)
        config.add_show_field solr_name("date_accepted", :stored_searchable)
        config.add_show_field solr_name("issue", :stored_searchable)
        config.add_show_field solr_name("volume", :stored_searchable)
        config.add_show_field solr_name("pagination", :stored_searchable)
        config.add_show_field solr_name("article_num", :stored_searchable)
        config.add_show_field solr_name("project_name", :stored_searchable)
        config.add_show_field solr_name("official_link", :stored_searchable)
        config.add_show_field solr_name("rights_holder", :stored_searchable)
        config.add_show_field solr_name("dewey", :stored_searchable)
        config.add_show_field solr_name("library_of_congress_classification", :stored_searchable)
        config.add_show_field solr_name('page_display_order_number', :stored_searchable)
        config.add_show_field solr_name('additional_links', :stored_searchable)
        config.add_show_field solr_name('irb_status', :stored_searchable)
        config.add_show_field solr_name('irb_number', :stored_searchable)

        # Re-configure search fields
        config.search_fields = {}
        config.add_search_field('all_fields', label: 'All Fields', include_in_advanced_search: false) do |field|
          all_names = config.show_fields.values.map(&:field).join(" ")
          title_name = solr_name("title", :stored_searchable)
          field.solr_parameters = {
            qf: "#{all_names} file_format_tesim all_text_timv alt_title_tesim^4.15 editor_display_ssim",
            pf: title_name.to_s
          }
        end

        # Now we see how to over-ride Solr request handler defaults, in this
        # case for a BL "search field", which is really a dismax aggregate
        # of Solr search fields.
        # creator, title, description, publisher, date_created,
        # subject, language, resource_type, format, identifier, based_near,
        config.add_search_field('contributor') do |field|
          # solr_parameters hash are sent to Solr as ordinary url query params.
          field.solr_parameters = { "spellcheck.dictionary": "contributor" }

          # :solr_local_parameters will be sent using Solr LocalParams
          # syntax, as eg {! qf=$title_qf }. This is neccesary to use
          # Solr parameter de-referencing like $title_qf.
          # See: http://wiki.apache.org/solr/LocalParams
          solr_name = "contributor_display_ssim"
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('creator') do |field|
          field.solr_parameters = { "spellcheck.dictionary": "creator" }
          solr_name = "creator_display_ssim"
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('editor') do |field|
          field.solr_parameters = { "spellcheck.dictionary": "editor" }
          solr_name = "editor_display_ssim"
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('title') do |field|
          field.solr_parameters = {
            "spellcheck.dictionary": "title"
          }
          solr_name = solr_name("title", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('description') do |field|
          field.label = "Abstract or Summary"
          field.solr_parameters = {
            "spellcheck.dictionary": "description"
          }
          solr_name = solr_name("description", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('publisher') do |field|
          field.solr_parameters = {
            "spellcheck.dictionary": "publisher"
          }
          solr_name = solr_name("publisher", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('date_created') do |field|
          field.solr_parameters = {
            "spellcheck.dictionary": "date_created"
          }
          solr_name = solr_name("created", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('subject') do |field|
          field.solr_parameters = {
            "spellcheck.dictionary": "subject"
          }
          solr_name = solr_name("subject", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('language') do |field|
          field.solr_parameters = {
            "spellcheck.dictionary": "language"
          }
          solr_name = solr_name("language", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('resource_type') do |field|
          field.solr_parameters = {
            "spellcheck.dictionary": "resource_type"
          }
          solr_name = solr_name("resource_type", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('format') do |field|
          field.include_in_advanced_search = false
          field.solr_parameters = {
            "spellcheck.dictionary": "format"
          }
          solr_name = solr_name("format", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('identifier') do |field|
          field.include_in_advanced_search = false
          field.solr_parameters = {
            "spellcheck.dictionary": "identifier"
          }
          solr_name = solr_name("id", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('based_near_label') do |field|
          field.label = "Location"
          field.solr_parameters = {
            "spellcheck.dictionary": "based_near_label"
          }
          solr_name = solr_name("based_near_label", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('keyword') do |field|
          field.solr_parameters = {
            "spellcheck.dictionary": "keyword"
          }
          solr_name = solr_name("keyword", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('depositor') do |field|
          solr_name = solr_name("depositor", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('rights_statement') do |field|
          solr_name = solr_name("rights_statement", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('license') do |field|
          solr_name = solr_name("license", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        config.add_search_field('extent') do |field|
          solr_name = solr_name("extent", :stored_searchable)
          field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
          }
        end

        # Re-configure sort fields
        config.sort_fields = {}
        config.add_sort_field "score desc, #{uploaded_field} desc", label: "relevance"
        config.add_sort_field "date_published_si desc, #{uploaded_field} desc", label: "date published \u25BC"
        config.add_sort_field "date_published_si asc, #{uploaded_field} desc", label: "date published \u25B2"

        # OAI Config fields
        config.oai = {
          provider: {
            # repository_name: ,
            repository_name: ->(controller) { controller.send(:current_account)&.name.presence || Settings.oai.name },
            # repository_url:  ->(controller) { controller.oai_catalog_url },
            record_prefix: Settings.oai.prefix,
            admin_email: ->(controller) { controller.send(:current_account).settings["oai_admin_email"].presence || Settings.oai.email },
            sample_id: Settings.oai.sample_id
          },
          document: {
            limit: 25, # number of records returned with each request, default: 15
            set_fields: [ # ability to define ListSets, optional, default: nil
              { label: 'collection', solr_field: 'isPartOf_ssim' }
            ]
          }
        }
      end
    end
  end
end
