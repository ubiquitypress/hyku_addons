# frozen_string_literal: true

# NOTE: The actor stack does not get this far for destroy, so that action is performed on the WorkBehavor
module HykuAddons
  module Actors
    module TaskMaster
      class WorkActor < Hyrax::Actors::AbstractActor
        def create(env)
          enqueue_job("upsert", env)

          next_actor.create(env)
        end

        def update(env)
          enqueue_job("upsert", env)

          next_actor.update(env)
        end

        protected

          def enqueue_job(action, env)
            return unless enabled? && env.curation_concern.upsertable?

            work = env.curation_concern

            HykuAddons::TaskMaster::PublishJob.perform_later(work.task_master_type, action, work.to_task_master.to_json)
          end

        private

          def enabled?
            Flipflop.enabled?(:task_master)
          end
      end
    end
  end
end
