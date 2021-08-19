# frozen_string_literal: true
module Hyrax
  # Generated form for NsuGenericWork
  class NsuGenericWorkForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::NsuGenericWork
    add_terms %i[title alt_title resource_type creator alt_email abstract
                 keyword subject degree qualification_level qualification_name
                 advisor org_unit date_published book_title alt_book_title
                 buy_book edition volume issue pagination version_number
                 official_link library_of_congress_classification
                 dewey mesh related_identifier adapted_from series_name source isbn
                 issn eissn publisher place_of_publication funder event_title event_location
                 event_date related_exhibition related_exhibition_venue related_exhibition_date
                 license rights_holder rights_statement contributor editor date_accepted
                 date_submitted table_of_contents references medium extent duration
                 language audience prerequisites location longitude latitude time
                 refereed suggested_reviewers suggested_student_reviewers irb_number
                 irb_status add_info]

    self.required_fields = %i[title resource_type creator keywords subject]
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator alt_email abstract
         keyword subject degree qualification_level qualification_name
         advisor org_unit date_published] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_email, :abstract, :keyword, :subject, :degree,
                             :qualification_level, :qualification_name, :advisor,
                             :org_unit, :date_published, :book_title,
                             :alt_book_title, :buy_book, :edition, :volume, :issue,
                             :pagination, :version_number, :official_link,
                             :library_of_congress_classification, :dewey, :mesh,
                             :related_identifier, :adapted_from, :series_name, :source,
                             :isbn, :issn, :eissn, :publisher, :place_of_publication,
                             :funder, :event_title, :event_location, :event_date,
                             :related_exhibition, :related_exhibition_venue,
                             :related_exhibition_date, :license, :rights_holder,
                             :rights_statement, :contributor, :editor, :date_accepted,
                             :date_submitted, :table_of_contents, :references,
                             :medium, :extent, :duration, :language, :audience,
                             :prerequisites, :location, :longitude, :latitude,
                             :time, :refereed, :suggested_reviewers, :suggested_student_reviewers,
                             :irb_number, :irb_status, :add_info]
      end
    end
  end
end
