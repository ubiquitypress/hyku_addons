# frozen_string_literal: true

module Hyrax
  class PacificThesisOrDissertationPresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    def self.delegated_methods
      [:volume, :pagination, :issn, :official_link,
       :journal_title, :issue, :institution, :org_unit, :refereed, :funder, :fndr_project_ref, :add_info,
       :date_published, :date_accepted, :date_submitted, :project_name, :rights_holder, :place_of_publication,
       :abstract, :alternate_identifier, :related_identifier, :creator_display,
       :library_of_congress_classification, :alt_title, :dewey,:location, :page_display_order_number,
       :title, :date_created, :description, :additional_links, :pagination, :degree].freeze
    end
  end
end
