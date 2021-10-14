# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverArticle`
module Hyrax
  class DenverArticlePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator abstract keyword subject org_unit
         date_published journal_title alternative_journal_title volume issue pagination
         alternate_identifier mesh related_identifier license rights_holder
         rights_statement contributor date_accepted date_submitted language refereed
         irb_number add_info institution].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
