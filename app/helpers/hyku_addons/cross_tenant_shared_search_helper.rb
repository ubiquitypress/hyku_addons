# frozen_string_literal: true

module HykuAddons
  module CrossTenantSharedSearchHelper
    def generate_work_url(model, request)
      cname = model["account_cname_tesim"]
      account_cname = Array.wrap(cname).first
      has_model = model["has_model_ssim"].first.underscore.pluralize
      id = model["id"]

      request_params = %i[protocol host port].map { |method| ["request_#{method}".to_sym, request.send(method)] }.to_h
      set_url(id: id, request: request_params, account_cname: account_cname, has_model: has_model)
    end

    def feature_for_display_in_proprietor_account_ui
      @feature_for_display_in_proprietor_account_ui ||= begin
        features = all_features.grouped_features.first.last
        features.select { |feature| feature.name == "cross_tenant_shared_search" }.compact
      end
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

      def set_url(id:, request:, account_cname:, has_model:)
        controller_path = has_model == "collections" ? has_model : "concern/#{has_model}"

        if Rails.env.development? || Rails.env.test?
          "#{request[:request_protocol]}#{account_cname || request[:request_host]}:#{request[:request_port]}/#{controller_path}/#{id}"
        else
          "#{request[:request_protocol]}#{account_cname || request[:request_host]}/#{controller_path}/#{id}"
        end
      end
  end
end
