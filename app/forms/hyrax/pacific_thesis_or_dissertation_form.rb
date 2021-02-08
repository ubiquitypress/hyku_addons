# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificThesisOrDissertation`
module Hyrax
  # Generated form for PacificThesisOrDissertation
  class PacificThesisOrDissertationForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificThesisOrDissertation
    add_terms %i[title alt_title resource_type creator contributor institution abstract date_published
                 pagination is_included_in publisher additional_links
                 rights_holder license degree org_unit doi subject keyword add_info]

    self.required_fields = %i[title resource_type creator institution org_unit]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :creator, :contributor, :date_published,
                             :pagination, :is_included_in, :publisher, :additional_links,
                             :degree, :org_unit, :subject, :keyword]
      end
    end
  end
end
