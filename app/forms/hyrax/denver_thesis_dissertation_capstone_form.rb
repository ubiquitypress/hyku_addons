# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverThesisDissertationCapstone`
module Hyrax
  # Generated form for DenverThesisDissertationCapstone
  class DenverThesisDissertationCapstoneForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::DenverThesisDissertationCapstone
    add_terms %i[title resource_type creator institution abstract keyword subject degree qualification_level
                 qualification_name advisor committee_member org_unit
                 date_published pagination alternate_identifier library_of_congress_classification
                 related_identifier publisher place_of_publication licence rights_holder rights_statement
                 contributor table_of_contents references medium extent language add_info]
    self.terms -= %i[related_url source]
    self.required_fields = %i[title creator resource_type abstract licence]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title resource_type creator] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:contributor, :extent, :language, :alternate_identifier,
                             :library_of_congress_classification, :publisher,
                             :related_identifier, :place_of_publication,
                             :licence, :rights_holder, :rights_statement,
                             :table_of_contents, :medium, :extent]
      end
    end
  end
end
