# frozen_string_literal: true

module Hyrax
  module Orcid
    module Strategy
      class SyncAll
        def initialize(work, identity)
          @work = work
          @identity = identity
        end

        def perform
          Hyrax::Orcid::OrcidWorkService.new(@work, @identity).publish
        end
      end
    end
  end
end
