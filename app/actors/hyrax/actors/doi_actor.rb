# frozen_string_literal: true

# Temporary fix until the Gem is patched and the following issue resolved:
# https://github.com/samvera-labs/hyrax-doi/issues/32
module Hyrax
  module Actors
    class DOIActor < BaseActor
      def create(env)
        create_or_update_doi(env.curation_concern) && next_actor.create(env)
      end

      def update(env)
        # Ensure that the work has any changed attributes persisted before we create the job
        apply_save_data_to_curation_concern(env) && save(env)

        create_or_update_doi(env.curation_concern) && next_actor.update(env)
      end

      delegate :destroy, to: :next_actor

      private

        def create_or_update_doi(work)
          # byebug
          return true unless doi_enabled_work_type?(work) && Flipflop.enabled?(:doi_minting)

          Hyrax::DOI::RegisterDOIJob.perform_later(work, registrar: work.doi_registrar.presence, registrar_opts: work.doi_registrar_opts)
        end

        # Check if work is DOI enabled
        def doi_enabled_work_type?(work)
          work.class.ancestors.include? Hyrax::DOI::DOIBehavior
        end
    end
  end
end
