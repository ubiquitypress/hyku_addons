# frozen_string_literal: true
module Hyrax
  class UnaThesisOrDissertationForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::UnaThesisOrDissertation
    add_terms %i[title resource_type creator alt_email abstract keyword subject
                 degree qualification_level qualification_name qualification_grantor
                 advisor committee_member org_unit date_published related_identifier
                 additional_links related_material related_url place_of_publication
                 citation license rights_holder rights_statement rights_statement_text
                 language location longitude latitude georeferenced add_info]
    self.terms -= %i[publisher source]
    self.required_fields = %i[title resource_type creator qualification_name qualification_level]

    include HykuAddons::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title resource_type creator alt_email abstract keyword subject
         degree qualification_level qualification_name qualification_grantor
         advisor committee_member org_unit date_published] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:title, :resource_type, :creator, :alt_email, :abstract,
                             :keyword, :subject, :degree, :qualification_level,
                             :qualification_name, :qualification_grantor, :advisor,
                             :committee_member, :org_unit, :date_published, :related_identifier,
                             :additional_links, :related_material, :related_url,
                             :place_of_publication, :citation, :license, :rights_holder,
                             :rights_statement, :rights_statement_text, :language,
                             :location, :longitude, :latitude, :georeferenced, :add_info]
      end
    end
  end
end
