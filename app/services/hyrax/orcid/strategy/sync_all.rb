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
          # TODO: Put this in a configuration object
          action = "perform_#{Rails.env.development? ? 'now' : 'later'}"
          Hyrax::Orcid::PublishWorkJob.send(action, @work, @identity)
        end
      end
    end
  end
end
