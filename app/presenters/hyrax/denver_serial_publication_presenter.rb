# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverSerialPublication`
module Hyrax
  class DenverSerialPublicationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator alt_email abstract keyword subject
         org_unit date_published journal_title journal_frequency volume
         issue pagination official_link alternate_identifier library_of_congress_classification
         related_identifier issn eissn publisher place_of_publication license
         rights_holder rights_statement contributor editor medium extent
         language location time refereed add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
