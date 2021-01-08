# frozen_string_literal: true
module Hyrax
  class TimeBasedMediaArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::TimeBasedMediaArticle
    self.terms = %i[title resource_type abstract add_info alt_title alternate_identifier event_title event_location event_date
                    contributor creator date_accepted date_published date_submitted dewey doi
                    fndr_project_ref funder institution keyword language library_of_congress_classification
                    license official_link org_unit place_of_publication project_name publisher related_identifier
                    related_url rights_holder rights_statement editor]
    self.required_fields = %i[title resource_type creator institution license]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << editor_fields
        permitted_params << %i[event_title event_location]
      end
    end

    def editor_list
      person_or_organization_list(:editor)
    end
  end
end
