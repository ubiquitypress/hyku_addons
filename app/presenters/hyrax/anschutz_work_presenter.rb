# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work AnschutzWork`
require 'hyku_addons/schema/presenter'
module Hyrax
  class AnschutzWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    # def self.delegated_methods
    #   [:alt_title, :abstract, :subject_text, :mesh, :date_published,
    #    :language, :place_of_publication, :license, :language, :add_info,
    #    :publisher, :source, :journal_frequency, :funding_description,
    #    :citation, :table_of_contents, :references, :extent, :advisor,
    #    :medium, :library_of_congress_classification, :committee_member,
    #    :time, :rights_statement, :subject, :qualification_grantor, :qualification_level,
    #    :qualification_name, :date_published_text, :qualification_subject_text, :rights_statement_text,
    #    :part_of, :is_format_of, :source_identifier].freeze
    # end

    include ::HykuAddons::Schema::Presenter(:anschutz_work)
    include ::HykuAddons::PresenterDelegatable
  end
end
