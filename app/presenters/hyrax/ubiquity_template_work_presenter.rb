# frozen_string_literal: true

module Hyrax
  class UbiquityTemplateWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::Schema::Presenter(:ubiquity_template_work)
    include ::HykuAddons::PresenterDelegatable
  end
end
