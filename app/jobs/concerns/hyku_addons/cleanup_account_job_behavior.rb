# frozen_string_literal: true
module HykuAddons
  module CleanupAccountJobBehavior
    extend ActiveSupport::Concern

    def perform(account)
      cleanup_solr(account)
      cleanup_fedora(account)
      cleanup_redis(account)
      # Store the UUID before the account is destroyed.
      # We need to destroy the account before the tenant database, or the account after_destroy callbacks
      # will not have the needed database tables to perform their actions.
      tenant = account.tenant
      account.destroy
      cleanup_database(tenant)
    end

    private

      def cleanup_database(tenant)
        Apartment::Tenant.drop(tenant)
      rescue StandardError
        nil
      end
  end
end
