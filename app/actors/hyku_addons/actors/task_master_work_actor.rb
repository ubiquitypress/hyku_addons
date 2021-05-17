# frozen_string_literal: true

module HykuAddons
  module Actors
    class TaskMasterWorkActor < Hyrax::Actors::AbstractActor
      def create(env)
        enqueue_job(env, action: "create")

        next_actor.create(env)
      end

      def update(env)
        enqueue_job(env, action: "update")

        next_actor.update(env)
      end

      def destroy(env)
        enqueue_job(env, action: "destroy")

        next_actor.destroy(env)
      end

      protected

        def enqueue_job(env, options = {})
          return unless enabled?

          TaskMasterWorkJob.perform_later(env.curation_concern.id, options)
        end

      private

        def enabled?
          Flipflop.enabled?(:task_master)
        end
    end
  end
end
