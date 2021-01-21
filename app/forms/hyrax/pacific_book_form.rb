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
    self.terms += %i[title alt_title resource_type creator contributor abstract date_published
                      pagination is_included_in volume buy_book publisher isbn issn additional_links
                      rights_holder license org_unit doi subject keyword refereed add_info
                    ]
    self.required_fields += %i[title creator org_unit pagination publisher]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
      end
    end
  end
end
