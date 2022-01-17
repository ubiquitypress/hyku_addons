# frozen_string_literal: true

module HykuAddons
  module StatsControllerBehavior
    extend ActiveSupport::Concern

    included do
      with_themed_layout "dashboard"

      before_action :build_breadcrumbs, only: [:work, :file, :reports]
      before_action :has_permission?, only: :reports
    end

    def reports
      @reports = Site.instance.account.dashboard_gds_charts.lines
    end

    protected

    def has_permission?
      return if current_user.has_role?(:admin, Site.instance)

      raise ActionController::RoutingError, "Not found"
    end
  end
end
