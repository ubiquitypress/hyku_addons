# frozen_string_literal: true

module Hyrax
  module Orcid
    class ProcessWorkJob < ApplicationJob
      queue_as Hyrax.config.ingest_queue_name

      def perform(work)
        return unless Flipflop.enabled?(:orcid_identities)

        HykuAddons::Orcid::ProcessWorkService.new(work).perform
      end
    end
  end
end
