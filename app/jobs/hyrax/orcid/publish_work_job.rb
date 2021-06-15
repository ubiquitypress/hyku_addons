# frozen_string_literal: true

module Hyrax
  module Orcid
    class PublishWorkJob < ApplicationJob
      queue_as Hyrax.config.ingest_queue_name

      def perform(work, identity)
        return unless Flipflop.enabled?(:orcid_identities)

        Hyrax::Orcid::SyncAllStrategy.new(work, identity).perform
      end
    end
  end
end

