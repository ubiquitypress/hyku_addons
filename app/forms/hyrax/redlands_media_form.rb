# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsMedia`
module Hyrax
  # Generated form for RedlandsMedia
  class RedlandsMediaForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::RedlandsMedia
    add_terms %i[title alt_title resource_type creator alt_email abstract keyword subject
                 org_unit language license date_published event_location official_link contributor location
                 longitude latitude add_info]
    self.terms -= %i[rights_statement related_url publisher]
    self.required_fields = %i[title resource_type creator alt_email abstract keyword subject
                              org_unit language date_published event_location]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator alt_email abstract keyword subject
         org_unit language license date_published event_location] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :alt_email, :edition, :book_title, :org_unit, :subject, :keyword,
                             :language, :version_number, :location, :longitude,
                             :latitude, :license, :event_location]
      end
    end
  end
end
