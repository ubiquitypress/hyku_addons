# frozen_string_literal: true

# Don't create fedora for a shared search tnant
module HykuAddons
  module CreateFcrepoEndpointJobOverride
    extend ActiveSupport::Concern

    def perform(account)
      return NilFcrepoEndpoint.new if account.shared_search_enabled?

      name = account.tenant.parameterize
      account.create_fcrepo_endpoint(base_path: "/#{name}")
    end
  end
end
