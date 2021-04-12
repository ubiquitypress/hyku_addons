# frozen_string_literal: true

module HykuAddons
  module GenericWorkPresenterBehavior
    extend ActiveSupport::Concern

    included do
      def self.delegated_methods
        [:volume, :pagination, :issn, :eissn, :contributor_display, :official_link, :series_name, :edition,
         :event_title, :event_date, :event_location, :book_title, :journal_title,
         :issue, :article_num, :isbn, :media, :related_exhibition, :related_exhibition_date,
         :version, :version_number, :alternative_journal_title, :related_exhibition_venue,
         :current_he_institution, :qualification_name, :qualification_level, :duration, :editor,
         :institution, :org_unit, :refereed, :funder, :fndr_project_ref, :add_info, :date_published,
         :date_accepted, :date_submitted, :project_name, :rights_holder, :place_of_publication,
         :abstract, :alternate_identifier, :related_identifier, :creator_display, :editor_display,
         :library_of_congress_classification, :alt_title, :dewey,
         :title, :date_created, :description, :export_as_ris].freeze
      end

      delegate(*delegated_methods, to: :solr_document)

      alias_method :isbns, :isbn
    end
  end
end
