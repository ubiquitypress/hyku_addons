# frozen_string_literal: true

# overriding flipflop
module HykuAddons
  module CrossTenantSharedSearchHelper
    def feature_for_display_in_proprietor_account_ui
      @feature_for_display_in_proprietor_account_ui = all_features.grouped_features.first.last.select { |feature| feature.name == "cross_tenant_shared_search" }.compact
    end

    def features_for_display_in_dashboard_ui
      dashboard_features_list = all_features.grouped_features[nil] - feature_for_display_in_proprietor_account_ui
      @all_features.grouped_features[nil] = dashboard_features_list
      @all_features
    end

    private

      def all_features
        @all_features = Flipflop::FeaturesController::FeaturesPresenter.new(Flipflop::FeatureSet.current)
      end
  end
end
