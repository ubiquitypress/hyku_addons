# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsOpenEducationalResource`
module Hyrax
  # Generated form for RedlandsOpenEducationalResource
  class RedlandsOpenEducationalResourceForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::RedlandsOpenEducationalResource
    add_terms %i[title alt_title resource_type creator alt_email abstract keyword subject
                 org_unit audience language license table_of_contents publisher place_of_publication date_published
                 edition pagination official_link adapted_from contributor related_material location longitude latitude
                 prerequisites suggested_student_reviewers suggested_reviewers add_info]
    self.terms -= %i[rights_statement related_url]
    self.required_fields = %i[title creator alt_email resource_type abstract keyword subject
                              org_unit language license table_of_contents publisher
                              place_of_publication date_published audience]

    include HykuAddons::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator alt_email abstract keyword subject
         org_unit audience language license table_of_contents publisher
         place_of_publication date_published]
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :alt_email, :edition, :org_unit, :subject, :keyword,
                             :language, :version_number, :location, :longitude,
                             :latitude, :license, :event_location, :edition, :pagination,
                             :official_link, :adapted_from, :audience, :related_material,
                             :prerequisites, :suggested_student_reviewers, :suggested_reviewers]
      end
    end
  end
end
