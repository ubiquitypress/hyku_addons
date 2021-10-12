# frozen_string_literal: true
module Hyrax
  class UnaBookForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::UnaBook
    add_terms %i[title alt_title resource_type creator alt_email abstract
                 keyword subject org_unit language license version_number
                 table_of_contents publisher place_of_publication date_published
                 edition isbn official_link series_name related_identifier
                 contributor location longitude latitude add_info buy_book]

    self.terms -= %i[source rights_statement]
    self.required_fields = %i[title resource_type creator alt_email abstract
                              keyword subject org_unit language license version_number
                              table_of_contents publisher place_of_publication date_published ]
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator alt_email abstract
         keyword subject org_unit language license version_number
         table_of_contents publisher place_of_publication date_published] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:title, :alt_title, :resource_type, :creator, :alt_email,
                             :abstract, :keyword, :subject, :org_unit, :language,
                             :license, :version_number, :table_of_contents, :publisher,
                             :place_of_publication, :date_published, :edition,
                             :isbn, :official_link, :series_name, :related_identifier,
                             :contributor, :location, :longitude, :latitude, :add_info,
                             :buy_book]
      end
    end
  end
end
