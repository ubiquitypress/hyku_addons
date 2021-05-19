# frozen_string_literal: true

module HykuAddons
  module TaskMaster
    module FileSetBehavior
      extend ActiveSupport::Concern

      include HykuAddons::TaskMaster::Publishable

      def task_master_type
        "file"
      end

      def task_master_uuid
        id
      end

      def to_task_master
        {
          uuid: task_master_uuid,
          work: member_of_works&.first&.id,
          name: label,
          metadata: attributes
        }
      end
    end
  end
end
