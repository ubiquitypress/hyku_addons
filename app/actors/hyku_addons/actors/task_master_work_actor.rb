# frozen_string_literal: true

module HykuAddons
  module Actors
    class TaskMasterWorkActor < Hyrax::Actors::AbstractActor
      def create(env)
        enqueue_job("create", env)

        next_actor.create(env)
      end

      def update(env)
        enqueue_job("update", env)

        next_actor.update(env)
      end

      def destroy(env)
        enqueue_job("destroy", env)

        next_actor.destroy(env)
      end

      protected

        def enqueue_job(action, env)
          return unless enabled?

          work = env.curation_concern

          HykuAddons::TaskMaster::PublishJob.perform_later(work.task_master_type, action, work.task_master_type.to_json)
        end

      private

        def enabled?
          Flipflop.enabled?(:task_master)
        end
    end
  end
end
