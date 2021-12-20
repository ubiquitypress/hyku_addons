# frozen_string_literal: true

module Hyrax
  class PacificImageForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificImage
    add_terms %i[title alt_title resource_type creator contributor abstract date_published
                 is_included_in publisher additional_links
                 rights_holder license org_unit official_link subject keyword add_info]
    self.terms -= %i[language rights_statement]
    self.required_fields = %i[title creator resource_type abstract org_unit]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :is_included_in, :publisher, :additional_links,
                             :org_unit, :subject, :keyword]
      end
    end
  end
end
