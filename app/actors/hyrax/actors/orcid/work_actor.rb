# frozen_string_literal: true

module Hyrax
  module Actors
    module Orcid
      class WorkActor < ::Hyrax::Actors::AbstractActor
        def create(env)
          process_work(env)

          next_actor.create(env)
        end

        def update(env)
          process_work(env)

          next_actor.update(env)
        end

        protected

          def process_work(env)
            return unless Flipflop.enabled?(:orcid_identities)

            action = "perform_#{Rails.env.development? ? 'now' : 'later'}"
            Hyrax::Orcid::ProcessWorkJob.send(action, env.curation_concern)
          end
      end
    end
  end
end
