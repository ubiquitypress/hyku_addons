# frozen_string_literal: true

module Hyrax
  module Actors
    module Orcid
      class WorkActor < ::Hyrax::Actors::AbstractActor
        def create(env)
          delegate_work_strategy(env)

          next_actor.create(env)
        end

        def update(env)
          delegate_work_strategy(env)

          next_actor.update(env)
        end

        def destroy(env)
          unpublish_work(env)

          next_actor.update(env)
        end

        protected

          def delegate_work_strategy(env)
            return unless enabled?

            # TODO: Put this in a configuration object
            action = "perform_#{Rails.env.development? ? 'now' : 'later'}"
            Hyrax::Orcid::IdentityStrategyDelegatorJob.send(action, env.curation_concern)
          end

          def unpublish_work(env)
            return unless enabled?

            # TODO: Put this in a configuration object
            action = "perform_#{Rails.env.development? ? 'now' : 'later'}"
            Hyrax::Orcid::WorkUnpublisherJob.send(action, env.curation_concern)
          end

        private

          def enabled?
            Flipflop.enabled?(:orcid_identities)
          end
      end
    end
  end
end
