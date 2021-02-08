# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificUncategorized`
module Hyrax
  # Generated form for PacificUncategorized
  class PacificUncategorizedForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificUncategorized
    add_terms %i[title alt_title resource_type creator contributor abstract
                 date_published duration version pagination is_included_in volume issue journal_title publisher isbn issn additional_links rights_holder license
                 doi degree org_unit subject keyword refereed irb_status irb_number add_info]

    self.required_fields = %i[title resource_type creator institution org_unit refereed]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :duration, :version_number, :pagination,
                             :is_included_in, :volume, :issue, :journal_title, :publisher,
                             :isbn, :issn, :additional_links, :degree, :org_unit, :subject,
                             :keyword, :refereed, :irb_status, :irb_number]
      end
    end
  end
end
