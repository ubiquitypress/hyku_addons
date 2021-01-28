# frozen_string_literal: true

module Hyrax
  class PacificBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificBook
    add_terms %i[title alt_title resource_type creator contributor abstract date_published
                 pagination is_included_in volume buy_book publisher isbn issn additional_links
                 rights_holder license org_unit doi subject keyword refereed add_info]

    self.required_fields = %i[title creator org_unit pagination publisher]
  end
end
