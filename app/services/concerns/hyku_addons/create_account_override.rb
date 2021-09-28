# frozen_string_literal: true

# skip creating defaults for shared search tenant
module HykuAddons
  module CreateAccountOverride
    extend ActiveSupport::Concern

    def create_defaults
      return if account.search_only?

      Hyrax::CollectionType.find_or_create_default_collection_type
      Hyrax::CollectionType.find_or_create_admin_set_type
      AdminSet.find_or_create_default_admin_set_id
    end
  end
end
