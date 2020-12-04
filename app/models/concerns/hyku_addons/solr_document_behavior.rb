# frozen_string_literal: true

module HykuAddons
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    included do
      attribute :extent, SolrDocument::Solr::Array, solr_name('extent')
      attribute :rendering_ids, SolrDocument::Solr::Array, solr_name('hasFormat', :symbol)
      attribute :isni, SolrDocument::Solr::Array, solr_name('isni')
      attribute :institution, SolrDocument::Solr::Array, solr_name('institution')
      attribute :org_unit, SolrDocument::Solr::Array, solr_name('org_unit')
      attribute :refereed, SolrDocument::Solr::Array, solr_name('refereed')
      attribute :funder, SolrDocument::Solr::Array, solr_name('funder')
      attribute :fndr_project_ref, SolrDocument::Solr::Array, solr_name('fndr_project_ref')
      attribute :add_info, SolrDocument::Solr::Array, solr_name('add_info')
      attribute :date_published, SolrDocument::Solr::Array, solr_name('date_published')
      attribute :date_accepted, SolrDocument::Solr::Array, solr_name('date_accepted')
      attribute :date_submitted, SolrDocument::Solr::Array, solr_name('date_submitted')
      attribute :journal_title, SolrDocument::Solr::Array, solr_name('journal_title')
      attribute :issue, SolrDocument::Solr::Array, solr_name('issue')
      attribute :volume, SolrDocument::Solr::Array, solr_name('volume')
      attribute :pagination, SolrDocument::Solr::Array, solr_name('pagination')
      attribute :article_num, SolrDocument::Solr::Array, solr_name('article_num')
      attribute :project_name, SolrDocument::Solr::Array, solr_name('project_name')
      attribute :rights_holder, SolrDocument::Solr::Array, solr_name('rights_holder')
      attribute :qualification_name, SolrDocument::Solr::Array, solr_name('qualification_name')
      attribute :qualification_level, SolrDocument::Solr::Array, solr_name('qualification_level')
      attribute :isbn, SolrDocument::Solr::Array, solr_name('isbn')
      attribute :issn, SolrDocument::Solr::Array, solr_name('issn')
      attribute :eissn, SolrDocument::Solr::Array, solr_name('eissn')
      attribute :current_he_institution, SolrDocument::Solr::Array, solr_name('current_he_institution')
      attribute :official_link, SolrDocument::Solr::Array, solr_name('official_link')
      attribute :place_of_publication, SolrDocument::Solr::Array, solr_name('place_of_publication')
      attribute :series_name, SolrDocument::Solr::Array, solr_name('series_name')
      attribute :edition, SolrDocument::Solr::Array, solr_name('edition')
      attribute :abstract, SolrDocument::Solr::Array, solr_name('abstract')
      attribute :event_title, SolrDocument::Solr::Array, solr_name('event_title')
      attribute :event_date, SolrDocument::Solr::Array, solr_name('event_date')
      attribute :event_location, SolrDocument::Solr::Array, solr_name('event_location')
      attribute :book_title, SolrDocument::Solr::Array, solr_name('book_title')
      attribute :alternate_identifier, SolrDocument::Solr::Array, solr_name('alternate_identifier')
      attribute :related_identifier, SolrDocument::Solr::Array, solr_name('related_identifier')
      attribute :version, SolrDocument::Solr::Array, solr_name('version')
      attribute :version_number, SolrDocument::Solr::Array, solr_name('version_number')
      attribute :media, SolrDocument::Solr::Array, solr_name('media')
      attribute :duration, SolrDocument::Solr::Array, solr_name('duration')
      attribute :related_exhibition, SolrDocument::Solr::Array, solr_name('related_exhibition')
      attribute :related_exhibition_venue, SolrDocument::Solr::Array, solr_name('related_exhibition_venue')
      attribute :related_exhibition_date, SolrDocument::Solr::Array, solr_name('related_exhibition_date')
      attribute :editor, SolrDocument::Solr::Array, solr_name('editor')
      attribute :creator_search, SolrDocument::Solr::Array, solr_name('creator_search')
      attribute :dewey, SolrDocument::Solr::Array, solr_name('dewey')
      attribute :library_of_congress_classification, SolrDocument::Solr::Array, solr_name('library_of_congress_classification')
      attribute :alt_title, SolrDocument::Solr::Array, solr_name('alt_title')
      attribute :alternative_journal_title, SolrDocument::Solr::Array, solr_name('alternative_journal_title')
      attribute :collection_names, SolrDocument::Solr::Array, solr_name('collection_names')
      attribute :collection_id, SolrDocument::Solr::Array, solr_name('collection_id')

      # Override OAI-PMH field mappings
      field_semantics.merge!(
        contributor: ['contributor_list_tesim', 'editor_list_tesim', 'funder_tesim'],
        creator: 'creator_search_tesim',
        date: 'date_published_tesim',
        description: 'abstract_oai_tesim',
        identifier: ['official_link_oai_tesim', 'doi_tesim', 'all_orcid_isni_tesim', 'work_tenant_url_tesim', 'collection_tenant_url_tesim'],
        relation: 'journal_title_tesim',
        rights: 'license_tesim',
        subject: 'keyword_tesim'
      )
    end
  end
end
