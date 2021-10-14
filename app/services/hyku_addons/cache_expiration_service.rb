# frozen_string_literal: true

module HykuAddons
  class CacheExpirationService
    def perform
      Account.all.find_each do |account|
        Rails.logger.info "Expiring cache for #{account.cname}"
        next if account.redis_endpoint.is_a?(NilRedisEndpoint)

        expire_cache_for(account)
      end
    end

    def expire_cache_for(account)
      account.redis_endpoint.switch!
      account.setup_tenant_cache(true)
      Rails.cache.clear
    end
  end
end
