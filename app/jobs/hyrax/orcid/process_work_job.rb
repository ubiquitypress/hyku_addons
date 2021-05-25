# frozen_string_literal: true

module Hyrax
  module Orcid
    class ProcessWorkJob < ApplicationJob
      queue_as Hyrax.config.ingest_queue_name

      def perform(orcid_id, work)
        # TODO: Check user preferences and send notificaions
        OrcidIdentity.find_by(orcid_id: orcid_id)&.sync_work(work)
      end
    end
  end
end
