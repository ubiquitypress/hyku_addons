# frozen_string_literal: true

module HykuAddons
  module StatsControllerBehavior
    extend ActiveSupport::Concern

    included do
      with_themed_layout "dashboard"

      before_action :build_breadcrumbs, only: [:work, :file, :reports]
      before_action :permission?, only: :reports
    end

    def reports
      @reports = account_gds_reports.lines.map do |chart|
        config = chart.split(",").map(&:strip)

        # Remove the first item from the array (the title) and return the rest for use in the select
        [config.delete_at(0), config.join(",")]
      end
    end

    protected

      def permission?
        # Ensure the user is signed in
        authorize! :read, Hyrax::Statistics

        return if current_user.has_role?(:admin, Site.instance) && Flipflop.enabled?(:gds_reports)

        raise ActionController::RoutingError, "Not found"
      end

      def account_gds_reports
        Site.instance.account.gds_reports || ""
      end
  end
end
