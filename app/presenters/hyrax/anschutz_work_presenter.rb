# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work AnschutzWork`
module Hyrax
  class AnschutzWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      [:alt_title, :abstract, :subject_text, :mesh,
       :language, :place_of_publication, :license, :language, :add_info,
       :publisher, :source, :journal_frequency, :funding_description,
       :citation, :table_of_contents, :references, :extent,
       :medium, :library_of_congress_classification, :committee_member,
       :time, :rights_statement, :subject, :qualification_grantor, :qualification_level,
       :qualification_name].freeze
    end

    include ::HykuAddons::PresenterDelegatable
  end
end
