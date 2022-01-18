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
      @reports = Site.instance.account.dashboard_gds_charts.lines.map do |chart|
        config = chart.split(",").map(&:strip)

        # Remove the first item from the array (the title) and return the rest
        [config.delete_at(0), config.join(",")]
      end
    end

    protected

      def has_permission?
        return if current_user.has_role?(:admin, Site.instance)

        raise ActionController::RoutingError, "Not found"
      end
  end
end
