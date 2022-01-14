# frozen_string_literal: true

module HykuAddons
  module StatsControllerBehavior
    extend ActiveSupport::Concern

    included do
      with_themed_layout "dashboard"

      before_action :build_breadcrumbs, only: [:work, :file, :reports]
    end

    def reports
      @reports = Site.instance.account.dashboard_gds_charts.lines
    end
  end
end
