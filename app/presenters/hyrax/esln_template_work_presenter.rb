# frozen_string_literal: true

module Hyrax
  class EslnTemplateWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:esln_template_work)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
