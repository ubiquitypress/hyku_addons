# frozen_string_literal: true

# overriding flipflop
module HykuAddons
  module CrossTenantSharedSearchHelper
    def generate_work_url(model, request)
      model = model.with_indifferent_access
      request_protocol = request.protocol || 'http://'
      request_port = request.port
      request_host = request.host

      cname = model["account_cname_tesim"]
      account_cname = cname.class == Array ? cname.try(:first) : cname

      has_model = model["has_model_ssim"].first.underscore.pluralize
      # returns a symbol not a string
      id = model[:id]
      request_params = { request_protocol: request_protocol, request_host: request_host, request_port: request_port }

      if has_model == "collections"
        set_collection_url(id: id, request: request_params, account_cname: account_cname, has_model: has_model)
      else
        set_work_url(id: id, request: request_params, account_cname: account_cname, has_model: has_model)
      end
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

      def set_work_url(id:, request:, account_cname:, has_model:)
        if Rails.env.development? || Rails.env.test?
          "#{request[:request_protocol]}#{account_cname || request[:request_host]}:#{request[:request_port]}/concern/#{has_model}/#{id}"
        else
          "#{request[:request_protocol]}#{account_cname || request[:request_host]}/concern/#{has_model}/#{id}"
        end
      end

      def set_collection_url(id:, request:, account_cname:, has_model:)
        if Rails.env.development? || Rails.env.test?
          "#{request[:request_protocol]}#{account_cname || request[:request_host]}:#{request[:request_port]}/#{has_model}/#{id}"
        else
          "#{request[:request_protocol]}#{account_cname || request[:request_host]}/#{has_model}/#{id}"
        end
      end
  end
end
