# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work AnschutzWork`
require 'hyku_addons/schema/presenter'
module Hyrax
  class AnschutzWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::Schema::Presenter(:anschutz_work)
    include ::HykuAddons::PresenterDelegatable
  end
end
