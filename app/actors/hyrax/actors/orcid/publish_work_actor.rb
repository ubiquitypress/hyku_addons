# frozen_string_literal: true

module Hyrax
  module Actors
    module Orcid
      class PublishWorkActor < ::Hyrax::Actors::AbstractActor
        def create(env)
          delegate_work_strategy(env)

          next_actor.create(env)
        end

        def update(env)
          delegate_work_strategy(env)

          next_actor.update(env)
        end

        protected

          def delegate_work_strategy(env)
            return unless enabled? && visible?(env)

            # TODO: Put this in a configuration object
            action = "perform_#{Rails.env.development? ? 'now' : 'later'}"
            Hyrax::Orcid::IdentityStrategyDelegatorJob.send(action, env.curation_concern)
          end

        private

          def visible?(env)
            env.curation_concern.visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          end

          def enabled?
            Flipflop.enabled?(:orcid_identities)
          end
      end
    end
  end
end
