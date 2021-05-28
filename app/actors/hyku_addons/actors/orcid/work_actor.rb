# frozen_string_literal: true

module HykuAddons
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

            HykuAddons::Orcid::ProcessWorkJob.perform_now(env.curation_concern)
          end
      end
    end
  end
end
