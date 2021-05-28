# frozen_string_literal: true

module HykuAddons
  module Orcid
    class ProcessWorkService
      include HykuAddons::WorkFormNameable

      # TARGET_TERMS = %i[creator contributor].freeze
      TARGET_TERMS = %i[creator].freeze

      def initialize(work)
        @work = work
      end

      # If the work includes our default processable terms
      def perform
        (TARGET_TERMS & work_type_terms).each { |term| process_term(term) }
      end

      def process_term(term)
        return unless (data = @work.send(term).first).present?

        JSON.parse(data).each do |participant|
          next unless (orcid_id = participant.dig("#{term}_orcid")).present?

          OrcidIdentity.find_by(orcid_id: orcid_id)&.sync_work!(@work)
        end
      end

      private

        # Required for WorkFormNameable to function correctly
        def meta_model
          @work.class.name
        end
    end
  end
end
