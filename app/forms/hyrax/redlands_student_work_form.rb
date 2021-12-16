# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsStudentWork`
module Hyrax
  # Generated form for RedlandsStudentWork
  class RedlandsStudentWorkForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::RedlandsStudentWork
    add_terms %i[title alt_title resource_type creator alt_email abstract keyword subject
                 qualification_name org_unit language license publisher date_published contributor location
                 longitude latitude advisor add_info]
    self.terms -= %i[rights_statement related_url]
    self.required_fields = %i[title resource_type creator alt_email abstract keyword subject
                              org_unit language publisher date_published]

    include HykuAddons::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator alt_email abstract keyword subject
         qualification_name org_unit language license publisher date_published] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :alt_email, :volume, :journal_title, :org_unit, :subject, :keyword,
                             :language, :location, :longitude, :latitude, :license, :advisor, :qualification_name]
      end
    end
  end
end
