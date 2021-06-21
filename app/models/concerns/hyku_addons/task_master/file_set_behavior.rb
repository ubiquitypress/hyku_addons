# frozen_string_literal: true

module HykuAddons
  module TaskMaster
    module FileSetBehavior
      extend ActiveSupport::Concern

      include HykuAddons::TaskMaster::Publishable

      included do
        after_update_index :task_master_publish_file_size
      end

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
          metadata: attributes.merge(file_set_charcterizations)
        }
      end

      # File entries will cause an error unless they have a valid work id
      def upsertable?
        work_id.present?
      end

      protected

        # FileSets will not have their metadata until after this has already ran 5 times (after 5 updates inside of
        # the actor stack). It's better to use the FileSet after_update_index hook which runs after metadata is added
        def publish_upsert; end

        def task_master_publish_file_size
          return unless analysed?

          publish(task_master_type, "upsert", to_task_master)
        end

        def file_set_charcterizations
          characterization_terms.map do |term|
            next unless characterization_proxy.respond_to?(term)

            [term, characterization_proxy.send(term)]
          end.compact.to_h
        end

        def work_id
          member_of_works&.first&.id
        end

        def analysed?
          original_file.present? && original_file.file_size.present?
        end
    end
  end
end
