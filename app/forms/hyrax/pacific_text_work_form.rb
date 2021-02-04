# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificTextWork`
module Hyrax
  # Generated form for PacificTextWork
  class PacificTextWorkForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificTextWork
    add_terms %i[title alt_title resource_type creator contributor abstract
                 date_published pagination is_included_in volume publisher issn source additional_links rights_holder license
                 org_unit doi subject keyword refereed add_info]

    self.required_fields = %i[title creator resource_type institution org_unit]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :pagination, :is_included_in, :volume, :publisher, :issn,
                             :source, :additional_links, :org_unit, :subject, :keyword, :refereed]
      end
    end
  end
end
