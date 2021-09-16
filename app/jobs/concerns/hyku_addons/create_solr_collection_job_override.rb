# frozen_string_literal: true

# Add ability to create  a real slr collection or a collection alias for a shared search tenant
module HykuAddons
  module CreateSolrCollectionJobOverride
    extend ActiveSupport::Concern

    def perform(account)
      name = account.tenant.parameterize

      perform_for_cross_search_tenant(account, name) if account.shared_search_tenant? && account.tenant_list.present?

      perform_for_normal_tenant(account, name) unless account.shared_search_tenant?
      account.add_parent_id_to_child if account.shared_search_tenant? && account.tenant_list.present?
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
        unless collection_exists? name
          client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATE',
                                                                                 name: name)
        end

        add_solr_endpoint_to_account(account, name)
      end

      def perform_for_cross_search_tenant(account, name)
        account_children = account.children.map(&:tenant)
        tenants_from_edit = account.tenant_list.to_set ^ account_children.to_set
        tenant_list = account.tenant_list.join(',')

        if account.children.empty?
          create_shared_search_collection(tenant_list, name)
          account.create_solr_endpoint(url: collection_url(name), collection: name)
        elsif tenants_from_edit.present?
          solr_config = account.solr_endpoint.connection_options.dup
          RemoveSolrCollectionJob.perform_now(name, solr_config, 'cross_search_tenant')

          account.remove_existing_child_records
          create_shared_search_collection(tenant_list, name)
          account.solr_endpoint.update(url: collection_url(name), collection: name)
        end
      end

      def create_shared_search_collection(tenant_list, name)
        return unless collection_exists? name

        client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATEALIAS',
                                                                               name: name, collections: tenant_list)
      end
  end
end
