# frozen_string_literal: true
module HykuAddons
  module CleanupAccountJobBehavior
    extend ActiveSupport::Concern

    def perform(account)
      cleanup_solr(account)
      cleanup_fedora(account)
      cleanup_redis(account)
      # Load the UUID on a variable before the account gets destroyed.
      # We need to destroy the account before the tenant DB or the account after_destroy callbacks
      # will not have the needed DB tables to make their actions.
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
