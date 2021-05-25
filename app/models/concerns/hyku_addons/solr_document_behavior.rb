# frozen_string_literal: true

module HykuAddons
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    class_methods do
      # Override to register the attributes for #attributes method below
      def attribute(name, type, field)
        registered_attributes << name
        define_method name do
          type.coerce(self[field])
        end
      end
    end

    def attributes
      registered_attributes.collect { |attr| [attr, send(attr)] }.to_h
    end

    included do
      class_attribute :registered_attributes
      # Pre-seed registered attributes because they have already been created before this module is included
      self.registered_attributes = [:doi, :identifier, :based_near, :based_near_label, :related_url, :resource_type,
                                    :edit_groups, :edit_people, :read_groups, :admin_set, :member_ids, :creator,
                                    :member_of_collection_ids, :description, :abstract, :title, :contributor, :subject,
                                    :publisher, :language, :keyword, :license, :source, :date_created, :rights_statement,
                                    :mime_type, :workflow_state, :human_readable_type, :representative_id, :rendering_ids,
                                    :thumbnail_id, :thumbnail_path, :label, :file_format, :suppressed?, :original_file_id,
                                    :date_modified, :date_uploaded, :create_date, :modified_date, :embargo_release_date,
                                    :lease_expiration_date, :add_info]

      attribute :file_size, SolrDocument::Solr::String, "file_size_lts"
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
      attribute :creator_display, SolrDocument::Solr::Array, 'creator_display_ssim'
      attribute :contributor_display, SolrDocument::Solr::Array, 'contributor_display_ssim'
      attribute :editor_display, SolrDocument::Solr::Array, 'editor_display_ssim'
      attribute :dewey, SolrDocument::Solr::Array, solr_name('dewey')
      attribute :library_of_congress_classification, SolrDocument::Solr::Array, solr_name('library_of_congress_classification')
      attribute :alt_title, SolrDocument::Solr::Array, solr_name('alt_title')
      attribute :alternative_journal_title, SolrDocument::Solr::Array, solr_name('alternative_journal_title')
      attribute :page_display_order_number, SolrDocument::Solr::Array, solr_name('page_display_order_number')
      attribute :additional_links, SolrDocument::Solr::Array, solr_name('additional_links')
      attribute :irb_status, SolrDocument::Solr::Array, solr_name('irb_status')
      attribute :irb_number, SolrDocument::Solr::Array, solr_name('irb_number')
      attribute :is_included_in, SolrDocument::Solr::Array, solr_name('is_included_in')
      attribute :degree, SolrDocument::Solr::Array, solr_name('degree')
      attribute :reading_level, SolrDocument::Solr::Array, solr_name('reading_level')
      attribute :challenged, SolrDocument::Solr::Array, solr_name('challenged')
      attribute :location, SolrDocument::Solr::Array, solr_name('location')
      attribute :outcome, SolrDocument::Solr::Array, solr_name('outcome')
      attribute :participant, SolrDocument::Solr::Array, solr_name('participant')
      attribute :photo_caption, SolrDocument::Solr::Array, solr_name('photo_caption')
      attribute :photo_description, SolrDocument::Solr::Array, solr_name('photo_description')
      attribute :buy_book, SolrDocument::Solr::Array, solr_name('buy_book')
      attribute :longitude, SolrDocument::Solr::Array, solr_name('longitude')
      attribute :latitude, SolrDocument::Solr::Array, solr_name('latitude')
      attribute :alt_email, SolrDocument::Solr::Array, solr_name('alt_email')
      attribute :alt_book_title, SolrDocument::Solr::Array, solr_name('alt_book_title')
      attribute :table_of_contents, SolrDocument::Solr::Array, solr_name('table_of_contents')

      # Override OAI-PMH field mappings
      field_semantics.merge!(
        contributor: ['contributor_display_ssim', 'editor_display_ssim', 'funder_tesim'],
        creator: 'creator_display_ssim',
        date: 'date_published_tesim',
        description: 'abstract_oai_tesim',
        identifier: ['official_link_oai_tesim', 'doi_tesim', 'all_orcid_isni_tesim', 'work_tenant_url_tesim', 'collection_tenant_url_tesim'],
        relation: 'journal_title_tesim',
        rights: 'license_tesim',
        subject: 'keyword_tesim'
      )
    end

    # Work out the reader class from the solr document model
    def meta_reader_class
      "Bolognese::Readers::#{@model.instance_variable_get(:@model)}Reader".constantize
    rescue NameError
      Bolognese::Readers::GenericWorkReader
    end
  end
end
