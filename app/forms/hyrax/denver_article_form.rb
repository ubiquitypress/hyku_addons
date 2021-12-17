# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverArticle`
module Hyrax
  # Generated form for DenverArticle
  class DenverArticleForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm
    self.model_class = ::DenverArticle
    add_terms %i[title alt_title resource_type creator institution abstract keyword subject org_unit
                 date_published journal_title alternative_journal_title volume issue pagination
                 alternate_identifier mesh related_identifier license rights_holder
                 rights_statement contributor date_accepted date_submitted language refereed
                 irb_number add_info]
    self.terms -= %i[related_url publisher source]
    self.required_fields = %i[title creator resource_type]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alternate_identifier, :related_identifier, :related_exhibition,
                             :related_exhibition_venue, :related_exhibition_date, :license, :rights_holder,
                             :rights_statement, :contributor, :extent, :language, :location, :longitude, :latitude,
                             :georeferenced, :add_info, :irb_number, :mesh]
      end
    end
  end
end
