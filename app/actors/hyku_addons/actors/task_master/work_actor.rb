# frozen_string_literal: true

module HykuAddons
  module Actors
    module TaskMaster
      class WorkActor < Hyrax::Actors::AbstractActor
        def create(env)
          enqueue_job("create", env) if enabled?

          next_actor.create(env)
        end

        def update(env)
          enqueue_job("update", env) if enabled?

          next_actor.update(env)
        end

        def destroy(env)
          enqueue_job("destroy", env) if enabled?

          next_actor.destroy(env)
        end

        protected

          def enqueue_job(action, env)
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
