# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificPresentation`
module Hyrax
  # Generated form for PacificPresentation
  class PacificPresentationForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificPresentation
    add_terms %i[title alt_title resource_type creator contributor abstract
                 date_published pagination is_included_in volume publisher issn additional_links rights_holder license
                 org_unit official_link subject keyword refereed add_info]
    self.terms -= %i[language rights_statement]
    self.required_fields = %i[title creator resource_type abstract org_unit]

    include HykuAddons::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :creator, :contributor, :date_published,
                             :pagination, :is_included_in, :volume, :publisher,
                             :issn, :additional_links, :org_unit, :subject, :keyword, :refereed]
      end
    end
  end
end
