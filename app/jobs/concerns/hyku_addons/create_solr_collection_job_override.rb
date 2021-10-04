# frozen_string_literal: true

# Add ability to create  a real slr collection or a collection alias for a shared search tenant
module HykuAddons
  module CreateSolrCollectionJobOverride
    extend ActiveSupport::Concern

    def perform(account)
      name = account.tenant.parameterize
      if account.search_only?
        perform_for_cross_search_tenant(account, name)
      else
        perform_for_normal_tenant(account, name)
      end
    end

    def without_account(name,  tenant_list = '')
      return if collection_exists?(name)

      if tenant_list.present?
        client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATEALIAS',
                                                                               name: name, collections: tenant_list)
      else
        client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATE',
                                                                               name: name)
      end
    end

    private

      def add_solr_endpoint_to_account(account, name)
        account.create_solr_endpoint(url: collection_url(name), collection: name)
      end

      def perform_for_normal_tenant(account, name)
        return if collection_exists? name

        client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATE',
                                                                               name: name)

        add_solr_endpoint_to_account(account, name)
      end

      def perform_for_cross_search_tenant(account, name)
        return unless account.full_accounts.present?

        if account.saved_changes&.[]('created_at').present? || account.solr_endpoint.is_a?(NilSolrEndpoint)
          create_shared_search_collection(account.full_accounts.map(&:tenant).uniq, name)
          account.create_solr_endpoint(url: collection_url(name), collection: name)
        else
          solr_options = account.solr_endpoint.connection_options.dup
          RemoveSolrCollectionJob.perform_now(name, solr_options, 'cross_search_tenant')
          create_shared_search_collection(account.full_accounts.map(&:tenant).uniq, name)
          account.solr_endpoint.update(url: collection_url(name), collection: name)
        end
      end

      def create_shared_search_collection(tenant_list, name)
        return self if collection_exists? name

        client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATEALIAS',
                                                                               name: name, collections: tenant_list)
      end
  end
end
