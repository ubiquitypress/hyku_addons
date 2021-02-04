# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificBook`
module Hyrax
  # Generated form for PacificBook
  class PacificBookForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificBook
    add_terms %i[title alt_title resource_type creator contributor abstract institution date_published
                 pagination is_included_in volume buy_book publisher isbn issn additional_links
                 rights_holder license org_unit doi subject keyword refereed add_info]

    self.required_fields = %i[title creator resource_type institution org_unit pagination publisher]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :pagination, :is_included_in, :volume,
                             :buy_book, :publisher, :isbn, :issn, :additional_links,
                             :org_unit, :subject, :keyword, :refereed]
      end
    end
  end
end
