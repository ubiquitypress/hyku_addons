# frozen_string_literal: true

module Hyrax
  class PacificBookForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificBook
    add_terms %i[title alt_title resource_type creator contributor abstract institution date_published
                 pagination is_included_in volume buy_book publisher isbn issn additional_links
                 rights_holder license org_unit doi subject keyword refereed add_info]
    self.terms -= %i[language rights_statement]
    self.required_fields = %i[title creator resource_type institution org_unit pagination publisher]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

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
