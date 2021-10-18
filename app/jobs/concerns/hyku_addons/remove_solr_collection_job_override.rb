# frozen_string_literal: true

# modify to handle removal of solr collection alias
module HykuAddons
  module RemoveSolrCollectionJobOverride
    extend ActiveSupport::Concern

    def perform(collection, connection_options, tenant_type = 'normal')
      if tenant_type == 'cross_search_tenant'
        solr_client(connection_options).get '/solr/admin/collections', params: { action: 'DELETEALIAS', name: collection }
      else
        solr_client(connection_options).get '/solr/admin/collections', params: { action: 'DELETE', name: collection }
      end
    end

    private

      def solr_client(connection_options)
        # We remove the adapter, otherwise RSolr 2 will try to use it as a Faraday middleware
        RSolr.connect(connection_options.without('adapter'))
      end
  end
end
