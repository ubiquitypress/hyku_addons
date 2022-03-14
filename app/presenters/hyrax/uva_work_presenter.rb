# frozen_string_literal: true

module Hyrax
  class UvaWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:uva_work)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
