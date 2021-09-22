# frozen_string_literal: true

# overriding flipflop
module HykuAddons
  module CrossTenantSharedSearchHelper
    def search_catalog_url(account: current_account, request:, locale: :en, search_field: 'all_fields')
      cname = account.parent&.cname
      return unless cname.present?

      local_url = "#{request.protocol}#{cname}:#{request.port}/catalog?utf8=✓&locale=#{locale}&search_field=#{search_field}&q="
      production_url = "#{request.protocol}#{cname}/catalog?utf8=✓&locale=en&search_field=#{search_field}&q="

      request.host.include?('hyku.docker') ? local_url : production_url
    end

    def enable_shared_search_check_box(f, account)
      f.check_box :shared_search, { checked: account.shared_search_tenant?, name: "account[settings][shared_search]", id: "account_settings_shared_search" }, true, false
    end

    def tenants_already_in_search(fetched_account:, account_under_edit:)
      check_box_tag "account[settings][tenant_list][]", fetched_account&.tenant,  account_under_edit.children.include?(fetched_account)
    end

    def not_in_search_checkbox(fetched_account:, account_under_edit:)
      check_box_tag "account[settings][tenant_list][]", fetched_account&.tenant, account_under_edit.children.include?(fetched_account)
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
