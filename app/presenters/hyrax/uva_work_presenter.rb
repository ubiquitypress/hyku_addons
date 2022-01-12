# frozen_string_literal: true

module Hyrax
  class UvaWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::Schema::Presenter(:uva_work)
    include ::HykuAddons::PresenterDelegatable
  end
end
