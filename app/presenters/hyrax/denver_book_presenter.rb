# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBook`
module Hyrax
  class DenverBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:denver_book)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
