# frozen_string_literal: true

# Add ability to create  a real slr collection or a collection alias for a shared search tenant
module HykuAddons
  module CreateSolrCollectionJobOverride
    extend ActiveSupport::Concern

    def perform(account)
      name = account.tenant.parameterize
      if account.shared_search_tenant? && account.tenant_list.present?
        perform_for_cross_search_tenant(account, name)
        account.add_parent_id_to_child
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
        tenant_list = account.tenant_list.join(',')

        remove_any_existing_shared_solr_collection(account, name)
        account.remove_existing_child_records

        create_shared_search_collection(tenant_list, name)
        add_solr_endpoint_to_account(account, name)
      end

      def remove_any_existing_shared_solr_collection(account, name)
        return if account.solr_endpoint.class == ::NilSolrEndpoint

        solr_config = account.solr_endpoint.connection_options.dup
        RemoveSolrCollectionJob.perform_now(name, solr_config, 'cross_search_tenant')
        account&.solr_endpoint&.destroy
      end

      def create_shared_search_collection(tenant_list, name)
        return self if collection_exists? name
        client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATEALIAS',
                                                                               name: name, collections: tenant_list)
      end
  end
end
