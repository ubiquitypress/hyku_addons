# frozen_string_literal: true

# overriding flipflop
module HykuAddons
  module CrossTenantSharedSearchHelper
    def redirect_to_shared_search_page
      cname = current_account.parent&.cname
      return unless cname.present?

      local_url = "#{request.protocol}#{cname}:#{request.port}/catalog?utf8=✓&locale=en&search_field=all_fields&q="
      production_url = "#{request.protocol}#{cname}/catalog?utf8=✓&locale=en&search_field=all_fields&q="

      request.host.include?('hyku.docker') ? local_url : production_url
    end

    def tenants_not_in_search(account)
      @list_for_unsaved_record = Account.not_cross_search_tenants_new_list - account.children
      @list_without_record_under_edit = Account.not_cross_search_tenants_edit_list(account.id) - account.children
      account.new_record? ? @list_for_unsaved_record : @list_without_record_under_edit
    end

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
