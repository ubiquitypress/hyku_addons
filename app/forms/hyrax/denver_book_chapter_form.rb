# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBookChapter`
module Hyrax
  # Generated form for DenverBookChapter
  class DenverBookChapterForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm
    self.model_class = ::DenverBookChapter
    add_terms %i[title alt_title resource_type creator institution abstract keyword
                 subject_text org_unit date_published book_title alt_book_title edition
                 pagination alternate_identifier library_of_congress_classification
                 related_identifier isbn publisher place_of_publication license
                 rights_holder rights_statement contributor editor medium language
                 time refereed add_info]
    self.terms -= %i[related_url source subject]
    self.required_fields = %i[title creator resource_type book_title rights_statement]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:title, :alt_title, :resource_type, :creator, :institution,
                             :abstract, :keyword, :subject_text, :org_unit, :date_published,
                             :book_title, :alt_book_title, :edition, :pagination,
                             :alternate_identifier, :library_of_congress_classification,
                             :related_identifier, :isbn, :publisher, :place_of_publication,
                             :license, :rights_holder, :rights_statement, :contributor,
                             :editor, :medium, :language, :time, :refereed, :add_info]
      end
    end
  end
end
