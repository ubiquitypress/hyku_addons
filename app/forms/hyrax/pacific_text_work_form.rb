# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificTextWork`
module Hyrax
  # Generated form for PacificTextWork
  class PacificTextWorkForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificTextWork
    add_terms %i[title alt_title resource_type creator contributor abstract
                 date_published pagination is_included_in volume publisher issn source additional_links rights_holder license
                 org_unit doi subject keyword refereed add_info]

    self.required_fields = %i[title creator resource_type institution org_unit]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :pagination, :is_included_in, :volume, :publisher, :issn,
                             :source, :additional_links, :org_unit, :subject, :keyword, :refereed]
      end
    end
  end
end
