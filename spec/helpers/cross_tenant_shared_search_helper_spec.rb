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

      it "returns truthy" do
        expect(proprietor_account_flipflop_features_list).to be_truthy
      end

      it "is an array" do
        expect(proprietor_account_flipflop_features_list).to be_an(Array)
      end

      it "contains Flipflop::FeatureDefinition in the array" do
        expect(proprietor_account_flipflop_features_list&.first).to be_an_instance_of(Flipflop::FeatureDefinition)
      end

      it "returns the correct feature key" do
        expect(proprietor_account_flipflop_features_list&.first&.key).to eq :cross_tenant_shared_search
      end
    end

    context "#features_for_display_in_dashboard_ui" do
      let(:dashboard_flipflop_features_list) { helper.features_for_display_in_dashboard_ui }

      it "does not include :cross_tenant_shared_search" do
        features_list = dashboard_flipflop_features_list.grouped_features[nil]&.map(&:key)
        expect(features_list).not_to include(:cross_tenant_shared_search)
      end
    end

    context "shared search records" do
      let(:cname) { "hyku-me.test" }
      let(:account) { build(:account, cname: cname) }

      let(:uuid) { SecureRandom.uuid }
      let(:request) { instance_double(ActionDispatch::Request, port: 3000, protocol: "https://", host: account.cname) }
      let(:attributes_hash) { { "id" => uuid, "has_model_ssim" => ['GenericWork'], "account_cname_tesim" => account.cname } }

      it "returns #generate_work_url for production" do
        allow(Rails.env).to receive(:development?).and_return(false)
        allow(Rails.env).to receive(:test?).and_return(false)

        url = "#{request.protocol}#{cname}/concern/generic_works/#{uuid}"
        expect(helper.generate_work_url(attributes_hash, request)).to eq(url)
      end

      it "returns #generate_work_url for development" do
        account.cname = "hyku.docker"
        url = "#{request.protocol}#{account.cname}:#{request.port}/concern/generic_works/#{uuid}"
        expect(helper.generate_work_url(attributes_hash, request)).to eq(url)
      end

      context "Collections" do
        let(:collection_klass) { ["Collection"] }

        it "set correct url in development" do
          account.cname = "hyku.docker"
          attributes_hash["has_model_ssim"] = collection_klass
          url = "#{request.protocol}#{account.cname}:#{request.port}/collections/#{uuid}"

          expect(helper.generate_work_url(attributes_hash, request)).to eq(url)
        end

        it "set correct url in production" do
          allow(Rails.env).to receive(:development?).and_return(false)
          allow(Rails.env).to receive(:test?).and_return(false)

          attributes_hash["has_model_ssim"] = collection_klass

          url = "#{request.protocol}#{account.cname}/collections/#{uuid}"
          expect(helper.generate_work_url(attributes_hash, request)).to eq(url)
        end
      end
    end
  end
end
