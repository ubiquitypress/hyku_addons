# frozen_string_literal: true

module HykuAddons
  module TaskMaster
    module WorkBehavior
      extend ActiveSupport::Concern

      def publishable?
        task_master_uuid.present?
      end

      def task_master_type
        "work"
      end

      def task_master_uuid
        id
      end

      def to_task_master
        {
          tenant: Site.instance.account.tenant,
          uuid: task_master_uuid,
          metadata: attributes
        }
      end
    end
  end
end
