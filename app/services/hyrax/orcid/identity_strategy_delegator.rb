# frozen_string_literal: true

# Take a work, extract its orcid ids, and for each orcid identity that is found
# create a seperate job to process the users identity sync strategy.
module Hyrax
  module Orcid
    class IdentityStrategyDelegator
      def initialize(work)
        @work = work

        validate!
      end

      # If the work includes our default processable terms
      def perform
        return unless Flipflop.enabled?(:orcid_identities)

        orcids = Hyrax::Orcid::WorkOrcidExtractor.new(@work).extract

        orcids.each { |orcid| perform_user_strategy(orcid) }
      end

      protected

        # Find the identity and farm out the rest of the logic to a background worker
        def perform_user_strategy(orcid_id)
          return unless (identity = OrcidIdentity.find_by(orcid_id: orcid_id)).present?

          # TODO: Put this in a configuration object
          action = "perform_#{Rails.env.development? ? 'now' : 'later'}"
          Hyrax::Orcid::PerformIdentityStrategyJob.send(action, @work, identity)
        end

        def validate!
          raise ArgumentError, "A work is required" unless @work.is_a?(ActiveFedora::Base)
        end
    end
  end
end
