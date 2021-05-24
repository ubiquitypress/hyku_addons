# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsConferencesReportsAndPaper`
module Hyrax
  # Generated form for RedlandsConferencesReportsAndPaper
  class RedlandsConferencesReportsAndPaperForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::RedlandsConferencesReportsAndPaper
    add_terms %i[title alt_title resource_type creator alt_email abstract keyword subject
                 org_unit language license publisher date_published event_location official_link
                 contributor location longitude latitude add_info]
    self.terms -= %i[rights_statement related_url]
    self.required_fields = %i[title creator alt_email resource_type abstract keyword subject
                              org_unit language license publisher date_published event_location]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator alt_email abstract keyword subject
         org_unit language license publisher date_published event_location]
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :alt_email, :volume, :journal_title, :org_unit, :subject, :keyword,
                             :language, :event_location, :location, :longitude, :latitude, :license]
      end
    end
  end
end
