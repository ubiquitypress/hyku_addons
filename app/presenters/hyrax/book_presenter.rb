# frozen_string_literal: true

module Hyrax
  class BookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      [:volume, :pagination, :issn, :eissn, :official_link,
       :issue, :article_num, :alternative_journal_title, :editor,
       :institution, :org_unit, :refereed, :funder, :fndr_project_ref, :add_info, :date_published,
       :date_accepted, :date_submitted, :project_name, :rights_holder, :place_of_publication,
       :abstract, :alternate_identifier, :related_identifier, :creator_display,
       :library_of_congress_classification, :alt_title, :dewey,
       :title, :date_created, :description].freeze
    end
    include ::HykuAddons::PresenterDelegatable

    # Must be included after delegated_methods
    include ::HykuAddons::EditorListable
  end
end
