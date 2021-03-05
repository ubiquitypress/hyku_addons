# frozen_string_literal: true

module Hyrax
  class DatasetPresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    DELEGATED_METHODS = [:institution, :org_unit, :refereed, :funder, :fndr_project_ref, :add_info, :date_published,
                         :date_accepted, :date_submitted, :project_name, :rights_holder, :place_of_publication,
                         :abstract, :alternate_identifier, :related_identifier, :creator,
                         :library_of_congress_classification, :alt_title, :dewey,
                         :title, :date_created, :description].freeze
  end
end
