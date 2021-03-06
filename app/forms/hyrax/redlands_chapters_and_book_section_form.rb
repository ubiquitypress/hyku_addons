# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsChaptersAndBookSection`
module Hyrax
  # Generated form for RedlandsChaptersAndBookSection
  class RedlandsChaptersAndBookSectionForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::RedlandsChaptersAndBookSection
    add_terms %i[title alt_title resource_type creator alt_email abstract keyword subject
                 org_unit language license version_number publisher place_of_publication date_published book_title
                 alt_book_title edition pagination isbn official_link series_name related_identifier contributor location
                 longitude latitude add_info buy_book]
    self.terms -= %i[rights_statement related_url]
    self.required_fields = %i[title creator alt_email resource_type abstract keyword subject
                              org_unit language license version_number publisher place_of_publication
                              date_published book_title]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator contributor alt_email abstract keyword subject
         org_unit language license version_number publisher place_of_publication date_published book_title] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :alt_email, :edition, :book_title, :org_unit, :subject, :keyword,
                             :language, :version_number, :issue, :pagination, :location, :longitude,
                             :latitude, :license, :buy_book]
      end
    end
  end
end
