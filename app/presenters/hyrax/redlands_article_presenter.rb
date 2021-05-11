# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsArticle`
module Hyrax
  class RedlandsArticlePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator alt_email abstract keyword subject org_unit
         language license version_number date_published journal_title volume issue
         pagination official_link related_identifier location longitude latitude add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
