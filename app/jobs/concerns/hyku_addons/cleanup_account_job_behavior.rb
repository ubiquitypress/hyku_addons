# frozen_string_literal: true
module HykuAddons
  module CleanupAccountJobBehavior
    extend ActiveSupport::Concern

    def perform(account)
      cleanup_solr(account)
      cleanup_fedora(account)
      cleanup_redis(account)
      tenant = account.tenant
      account.destroy
      cleanup_database(tenant)
    end

    private

      def cleanup_database(tenant)
        Apartment::Tenant.drop(tenant)
      rescue StandardError
        nil # ignore if account.tenant missing
      end
  end
end
