# frozen_string_literal: true

module Hyrax
  module Orcid
    class PerformIdentityStrategyJob < ApplicationJob
      queue_as Hyrax.config.ingest_queue_name

      def perform(work, identity)
        return unless Flipflop.enabled?(:orcid_identities)

        "Hyrax::Orcid::#{identity.work_sync_preference.classify}Strategy".constantize.new(work, identity).perform
      end
    end
  end
end

