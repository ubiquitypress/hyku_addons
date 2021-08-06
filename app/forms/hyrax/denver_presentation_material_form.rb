# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverPresentationMaterial`
module Hyrax
  # Generated form for DenverPresentationMaterial
  class DenverPresentationMaterialForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm
    self.model_class = ::DenverPresentationMaterial
    add_terms %i[title resource_type creator institution abstract keyword subject org_unit
                 date_published related_identifier event_title event_location event_date
                 licence rights_holder rights_statement contributor language add_info]
    self.terms -= %i[related_url source publisher]
    self.required_fields = %i[title creator resource_type]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title resource_type creator] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:contributor, :language, :add_info,
                             :alternate_identifier, :related_identifier,
                             :licence, :rights_holder, :rights_statement]
      end
    end
  end
end
