# frozen_string_literal: true

module HykuAddons
  module Actors
    class TaskMasterModelActor < Hyrax::Actors::AbstractActor
      def create(env)
        enqueue_job(env) if enabled?

        next_actor.create(env)
      end

      def update(env)
        enqueue_job(env) if enabled?

        next_actor.update(env)
      end

      def destroy(env)
        enqueue_job(env) if enabled?

        next_actor.destroy(env)
      end

      protected

        def enqueue_job(env)
          TaskMasterWorkJob.perform_later(env.curation_concern.id)
        end

      private

        def enabled?
          Flipflop.enabled?(:task_master)
        end
    end
  end
end
