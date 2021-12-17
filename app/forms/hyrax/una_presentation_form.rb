# frozen_string_literal: true
module Hyrax
  class UnaPresentationForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::UnaPresentation
    add_terms %i[title alt_title resource_type creator alt_email abstract keyword
                 subject org_unit language license publisher date_published event_location
                 official_link mentor contributor location longitude latitude add_info
                 event_title event_location event_date]
    self.terms -= %i[rights_statement related_url source]
    self.required_fields = %i[title creator resource_type alt_email abstract keyword
                              subject org_unit language license publisher date_published]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator alt_email abstract keyword
         subject org_unit language license publisher date_published] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:title, :alt_title, :resource_type, :creator, :alt_email,
                             :abstract, :keyword, :subject, :org_unit, :language,
                             :license, :publisher, :date_published, :event_location,
                             :official_link, :contributor, :location, :longitude,
                             :latitude, :add_info, :event_title, :event_date, :mentor]
      end
    end
  end
end
