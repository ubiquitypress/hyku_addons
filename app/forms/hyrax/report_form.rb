# frozen_string_literal: true

module Hyrax
  class ReportForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::Report
    add_terms %i[title resource_type creator alt_title contributor abstract date_published
                 institution org_unit project_name funder fndr_project_ref series_name editor volume
                 edition publisher place_of_publication isbn issn eissn date_accepted date_submitted official_link
                 related_url language license rights_statement rights_holder doi alternate_identifier related_identifier
                 refereed keyword dewey library_of_congress_classification add_info pagination rendering_ids]
    self.required_fields = %i[title resource_type creator institution date_published]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
  end
end
