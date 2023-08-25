# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverThesisDissertationCapstone`
module Hyrax
  class DenverThesisDissertationCapstonePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:denver_thesis_dissertation_capstone)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
