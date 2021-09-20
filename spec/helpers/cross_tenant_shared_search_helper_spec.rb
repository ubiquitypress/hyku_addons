# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::CrossTenantSharedSearchHelper do
  include Devise::Test::ControllerHelpers

  let(:helper) { _view }

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
  end

  describe "cross_tenant_shared_search_helper" do
    context '#feature_for_display_in_proprietor_account_ui' do
      let(:proprietor_account_flipflop_features_list) { helper.feature_for_display_in_proprietor_account_ui }

      it 'returns truthy' do
        expect(proprietor_account_flipflop_features_list).to be_truthy
      end

      it 'is an array' do
        expect(proprietor_account_flipflop_features_list).to be_an(Array)
      end

      it 'contains Flipflop::FeatureDefinition in the array' do
        expect(proprietor_account_flipflop_features_list&.first).to be_an_instance_of(Flipflop::FeatureDefinition)
      end

      it 'returns the correct feature key' do
        expect(proprietor_account_flipflop_features_list&.first&.key).to eq :cross_tenant_shared_search
      end
    end

    context '#features_for_display_in_dashboard_ui' do
      let(:dashboard_flipflop_features_list) { helper.features_for_display_in_dashboard_ui }

      it 'does not include :cross_tenant_shared_search' do
        features_list = dashboard_flipflop_features_list.grouped_features[nil]&.map(&:key)
        expect(features_list).not_to include(:cross_tenant_shared_search)
      end
    end
  end
end
