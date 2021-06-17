# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work AnschutzWork`
module Hyrax
  # Generated form for AnschutzWork
  class AnschutzWorkForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.terms = []
    self.required_fields = []

    include Hyrax::FormFields(:anschutz_work)

    self.model_class = ::AnschutzWork
    #    add_terms %i[title alt_title creator date_published abstract resource_type license
    #                 place_of_publication language subject_text mesh add_info contributor publisher source
    #                 journal_frequency funding_description citation table_of_contents
    #                 references extent medium library_of_congress_classification]
    #    self.terms -= %i[related_url rights_statement]
    #    self.required_fields = %i[title resource_type creator date_published abstract license]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    #    def primary_terms
    #      %i[title alt_title creator date_published abstract resource_type license
    #         place_of_publication language subject_text mesh add_info] | super
    #    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :abstract, :subject_text, :mesh,
                             :language, :place_of_publication, :license, :language, :add_info,
                             :publisher, :source, :journal_frequency, :funding_description,
                             :citation, :table_of_contents, :references, :extent,
                             :medium, :library_of_congress_classification]
      end
    end
  end
end
