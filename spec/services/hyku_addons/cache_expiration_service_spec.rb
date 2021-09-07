# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::CacheExpirationService do
  let(:service) { described_class.new }
  let(:account) do
    account = create(:account, name: 'tenant')
    account.create_redis_endpoint!
    account
  end

  before do
    account
  end

  describe "perform" do
    before do
      allow(service).to receive(:expire_cache_for)
      service.perform
    end

    it "updates the frontend_url of the Account" do
      expect(service).to have_received(:expire_cache_for).once
    end
  end

  describe "expire_cache_for" do
    let(:mock_cache) { instance_double("ActiveSupport::Cache::RedisCacheStore", clear: nil) }

    before do
      allow(ActiveSupport::Cache).to receive(:lookup_store).and_return(mock_cache)
      service.perform
    end

    it "clears the tenant Rails cache" do
      expect(mock_cache).to have_received(:clear)
    end
  end
end
