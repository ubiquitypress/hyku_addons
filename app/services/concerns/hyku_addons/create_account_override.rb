# frozen_string_literal: true

require_dependency "hyrax/search_state"

# skip creating defaults for shared search tenant
module HykuAddons
  module CreateAccountOverride
    extend ActiveSupport::Concern

    def create_account_inline
      CreateAccountInlineJob.perform_now(account) && account.create_datacite_endpoint
    end

    def create_defaults
      return if account.search_only?

      Hyrax::CollectionType.find_or_create_default_collection_type
      Hyrax::CollectionType.find_or_create_admin_set_type
      AdminSet.find_or_create_default_admin_set_id
    end
  end
end
