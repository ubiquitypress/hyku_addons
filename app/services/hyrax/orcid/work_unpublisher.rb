# frozen_string_literal: true

module Hyrax
  module Orcid
    class WorkUnpublisher
      def initialize(work)
        @work = work
      end

      # If the work includes our default processable terms
      def perform
        orcids = Hyrax::Orcid::WorkOrcidExtractor.new(@work).extract

        orcids.each { |orcid| unpublish_work(orcid) }
      end

      protected

        # Find the identity and farm out the rest of the logic to a background worker
        def unpublish_work(orcid_id)
          return unless (identity = OrcidIdentity.find_by(orcid_id: orcid_id)).present?

          Hyrax::Orcid::OrcidWorkService.new(@work, identity).unpublish
        end
    end
  end
end

