# frozen_string_literal: true
module Hyrax
  class UnaArticleForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::UnaArticle
    add_terms %i[title resource_type creator alt_email abstract
                 keyword subject date_published journal_title alternative_journal_title
                 journal_frequency volume issue pagination article_num version_number
                 official_link alternate_identifier library_of_congress_classification
                 dewey related_identifier adapted_from additional_links related_material
                 related_url issn eissn publisher place_of_publication citation
                 funder project_name fndr_project_ref funding_description license date_accepted
                 date_submitted location longitude latitude georeferenced time
                 refereed irb_number irb_status add_info]

    self.terms -= %i[source contributor rights_statement language]
    self.required_fields = %i[title resource_type creator journal_title]
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title resource_type creator alt_email abstract
         keyword subject date_published journal_title] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:title, :resource_type, :creator, :alt_email, :abstract,
                             :keyword, :subject, :date_published, :journal_title,
                             :alternative_journal_title, :journal_frequency, :volume,
                             :issue, :pagination, :article_num, :version_number, :official_link,
                             :alternate_identifier, :library_of_congress_classification,
                             :dewey, :related_identifier, :adapted_from, :additional_links,
                             :related_material, :related_url, :issn, :eissn, :publisher,
                             :place_of_publication, :citation, :funder, :project_name,
                             :fndr_project_ref, :funding_description, :date_accepted,
                             :date_submitted, :license, :location, :longitude, :latitude,
                             :georeferenced, :time, :refereed, :irb_number, :irb_status, :add_info]
      end
    end
  end
end
