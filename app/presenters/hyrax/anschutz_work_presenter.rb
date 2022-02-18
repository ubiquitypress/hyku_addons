# frozen_string_literal: true

module Hyrax
  class AnschutzWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::Schema::Presenter(:anschutz_work)
    include ::HykuAddons::PresenterDelegatable
  end
end
