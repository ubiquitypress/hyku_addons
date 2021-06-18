# frozen_string_literal: true

module Hyrax
  module Actors
    module Orcid
      class UnpublishWorkActor < ::Hyrax::Actors::AbstractActor
        def destroy(env)
          unpublish_work(env)

          next_actor.destroy(env)
        end

        protected

          def unpublish_work(env)
            return unless enabled?

            # TODO: Put this in a configuration object
            action = "perform_#{Rails.env.development? ? 'now' : 'later'}"
            Hyrax::Orcid::UnpublishWorkDelegatorJob.send(action, env.curation_concern)
          end

        private

          def enabled?
            Flipflop.enabled?(:orcid_identities)
          end
      end
    end
  end
end
