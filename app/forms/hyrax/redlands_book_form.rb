# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsBook`
module Hyrax
  # Generated form for RedlandsBook
  class RedlandsBookForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::RedlandsBook
    add_terms %i[title alt_title resource_type creator alt_email abstract keyword subject
                 org_unit language license version_number table_of_contents publisher place_of_publication date_published
                 edition isbn official_link series_name related_identifier contributor location longitude latitude add_info buy_book]
    self.terms -= %i[rights_statement publisher related_url]
    self.required_fields = %i[title creator alt_email resource_type abstract keywork subject
                              org_unit language license version_number publisher place_of_publication
                              date_published book_title]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :alt_email, :edition, :book_title, :org_unit, :subject, :keyword,
                             :language, :version_number, :issue, :pagination, :location, :longitude,
                             :latitude, :license, :isbn]
      end
    end
  end
end
