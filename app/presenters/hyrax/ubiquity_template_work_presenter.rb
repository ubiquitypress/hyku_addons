# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work TemplateWork`
module Hyrax
  class UbiquityTemplateWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract date_published media duration
         institution org_unit project_name funder fndr_project_ref event_title event_location event_date
         series_name book_title editor journal_title alternative_journal_title volume edition version_number issue
         pagination article_num publisher place_of_publication isbn issn eissn current_he_institution date_accepted
         date_submitted official_link related_url related_exhibition related_exhibition_venue related_exhibition_date
         language license rights_statement rights_holder doi qualification_name qualification_level draft_doi
         alternate_identifier related_identifier refereed keyword dewey library_of_congress_classification add_info
         page_display_order_number irb_number irb_status subject additional_links is_included_in buy_book challenged
         location outcome participant reading_level photo_caption photo_description degree longitude latitude alt_email
         alt_book_title table_of_contents prerequisites suggested_student_reviewers suggested_reviewers adapted_from audience
         related_material note advisor subject_text mesh journal_frequency funding_description
         citation references extent medium source committee_member time qualification_grantor date_published_text
         rights_statement_text qualification_subject_text].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
