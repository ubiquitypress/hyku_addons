# frozen_string_literal: true

module Hyrax
  module Orcid
    class UnpublishWorkDelegatorJob < ApplicationJob
      queue_as Hyrax.config.ingest_queue_name

      def perform(work)
        return unless Flipflop.enabled?(:orcid_identities)

        Hyrax::Orcid::WorkUnpublisherDelegator.new(work).perform
      end
    end
  end
end

