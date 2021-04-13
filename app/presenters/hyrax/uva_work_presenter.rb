# frozen_string_literal: true

module Hyrax
  class UvaWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title resource_type creator abstract license keyword contributor language
         publisher date_published related_url funder add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
