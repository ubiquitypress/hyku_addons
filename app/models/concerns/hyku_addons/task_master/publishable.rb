# frozen_string_literal: true

module HykuAddons
  module TaskMaster
    module Publishable
      extend ActiveSupport::Concern

      included do
        after_create :publish_create
        after_update :publish_update
        after_destroy :publish_destroy
      end

      def to_task_master
        raise NotImplementedError
      end

      def task_master_uuid
        raise NotImplementedError
      end

      def task_master_type
        raise NotImplementedError
      end

      protected

        def publish_create
          publish(task_master_type, "create", to_task_master)
        end

        def publish_update
          publish(task_master_type, "update", to_task_master)
        end

        def publish_destroy
          publish(task_master_type, "destroy", to_task_master)
        end

        def publish(type, action, data)
          return unless enabled?

          HykuAddons::TaskMaster::PublishJob.perform_later(type, action, data.to_json)
        end

      private

        def enabled?
          Flipflop.enabled?(:task_master)
        end
    end
  end
end
