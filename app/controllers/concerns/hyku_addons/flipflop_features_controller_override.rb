# frozen_string_literal: true

# Removes :cross_search_tenant from features list for dashbaord
module HykuAddons
  module FlipflopFeaturesControllerOverride
    extend ActiveSupport::Concern

    def index
      @feature_set = helpers.features_for_display_in_dashboard_ui
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyrax.admin.sidebar.configuration'), '#'
      add_breadcrumb t(:'hyrax.admin.sidebar.technical'), hyrax.admin_features_path
      render
    end
  end
end
