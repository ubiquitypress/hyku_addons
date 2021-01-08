# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work BookContribution`
module Hyrax
  class BookContributionPresenter < Hyrax::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    DELEGATED_METHODS = [:volume, :pagination, :issn, :eissn, :official_link,
                         :issue, :article_num, :alternative_journal_title,
                         :institution, :org_unit, :refereed, :funder, :fndr_project_ref, :add_info, :date_published,
                         :date_accepted, :date_submitted, :project_name, :rights_holder, :place_of_publication,
                         :abstract, :alternate_identifier, :related_identifier, :creator_display,
                         :library_of_congress_classification, :alt_title, :dewey,
                         :title, :date_created, :description].freeze
  end
end
