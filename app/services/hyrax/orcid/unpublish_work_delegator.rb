# frozen_string_literal: true

# Organise the data required to unpublish the work for each of the contributors, and create a job for each
module Hyrax
  module Orcid
    class UnpublishWorkDelegator
      def initialize(work)
        @work = work
      end

      # If the work includes our default processable terms
      def perform
        orcids = Hyrax::Orcid::WorkOrcidExtractor.new(@work).extract

        orcids.each { |orcid| delegate(orcid) }
      end

      protected

        # Find the identity and farm out the rest of the logic to a background worker
        def delegate(orcid_id)
          return unless (identity = OrcidIdentity.find_by(orcid_id: orcid_id)).present?

          # TODO: Put this in a configuration object
          action = "perform_#{Rails.env.development? ? 'now' : 'later'}"
          Hyrax::Orcid::UnpublishWorkJob.send(action, @work, identity)
        end
    end
  end
end
