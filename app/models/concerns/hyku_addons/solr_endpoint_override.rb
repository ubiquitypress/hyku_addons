# frozen_string_literal: true

# Remove the solr collection then destroy this record
module HykuAddons
  module SolrEndpointOverride
    extend ActiveSupport::Concern

    def remove!
      # Spin off as a job, so that it can fail and be retried separately from the other logic.
      if account.shared_search_enabled?
        RemoveSolrCollectionJob.perform_later(collection, connection_options, 'cross_search_tenant')
      else
        RemoveSolrCollectionJob.perform_later(collection, connection_options)
      end
      destroy
    end
  end
end
