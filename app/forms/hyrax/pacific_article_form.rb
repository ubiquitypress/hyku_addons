# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificArticle`
module Hyrax
  # Generated form for PacificArticle
  class PacificArticleForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificArticle
    add_terms %i[title alt_title resource_type creator contributor abstract institution date_published pagination issue page_display_order_number
                 volume journal_title publisher issn source additional_links
                 rights_holder license org_unit doi subject keyword refereed
                 irb_status irb_number add_info]

    self.required_fields = %i[title creator resource_type institution org_unit]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :pagination, :issue, :page_display_order_number,
                             :volume, :journal_title, :publisher, :issn, :source,
                             :additional_links, :org_unit, :subject, :keyword,
                             :refereed, :irb_status, :irb_number]
      end
    end
  end
end
