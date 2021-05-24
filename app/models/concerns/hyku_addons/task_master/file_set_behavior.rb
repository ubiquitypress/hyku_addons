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
          work: work_id,
          name: label,
          metadata: attributes
        }
      end

      # File entries will cause an error unless they have a valid work id
      def upsertable?
        work_id.present?
      end

      protected

        def work_id
          member_of_works&.first&.id
        end
    end
  end
end
