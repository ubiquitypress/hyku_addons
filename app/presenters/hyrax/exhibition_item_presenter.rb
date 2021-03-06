# frozen_string_literal: true

module Hyrax
  class ExhibitionItemPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      [:version, :pagination, :issn, :eissn, :official_link,
       :journal_title, :issue, :article_num, :alternative_journal_title,
       :institution, :org_unit, :refereed, :funder, :fndr_project_ref, :add_info, :date_published,
       :date_accepted, :date_submitted, :project_name, :rights_holder, :place_of_publication,
       :abstract, :alternate_identifier, :related_identifier, :creator_display,
       :library_of_congress_classification, :alt_title, :dewey,
       :title, :date_created, :description, :related_exhibition, :related_exhibition_venue,
       :place_of_publication].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
