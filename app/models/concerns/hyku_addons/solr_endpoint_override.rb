# frozen_string_literal: true

# Remove the solr collection then destroy this record
module HykuAddons
  module SolrEndpointOverride
    extend ActiveSupport::Concern

    def remove!
      # Spin off as a job, so that it can fail and be retried separately from the other logic.
      RemoveSolrCollectionJob.perform_later(collection, connection_options, account.search_only?)
      destroy
    end
  end
end
