# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificMedia`
module Hyrax
  class PacificMediaForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificMedia
    add_terms %i[title alt_title resource_type creator contributor abstract
                 date_published duration version_number is_included_in
                 publisher additional_links rights_holder license
                 org_unit doi subject keyword refereed add_info]
    self.terms -= %i[language rights_statement]
    self.required_fields = %i[title creator resource_type org_unit]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :duration, :version_number, :is_included_in,
                             :publisher, :additional_links, :org_unit, :subject,
                             :keyword, :refereed]
      end
    end
  end
end
