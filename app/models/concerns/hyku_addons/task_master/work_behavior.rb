# frozen_string_literal: true

module HykuAddons
  module TaskMaster
    module WorkBehavior
      extend ActiveSupport::Concern

      include HykuAddons::TaskMaster::Publishable

      def upsertable?
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
          tenant: Site.instance&.account&.tenant,
          uuid: task_master_uuid,
          metadata: attributes
        }
      end

      protected

        # Upsert for works is performed inside the actor stack
        def publish_upsert; end
    end
  end
end
