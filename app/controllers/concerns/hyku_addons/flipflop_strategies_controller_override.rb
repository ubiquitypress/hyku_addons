# frozen_string_literal: true

# stops redirect_to dashboard when updating featires from proprietor_accounts
module HykuAddons
  module FlipflopStrategiesControllerOverride
    extend ActiveSupport::Concern

    def update
      ::Flipflop::FeatureSet.current.switch!(feature_key, strategy_key, enable?)
      return redirect_to(main_app.proprietor_accounts_url) if feature_key == :cross_tenant_shared_search
      redirect_to(features_url)
    end
  end
end
