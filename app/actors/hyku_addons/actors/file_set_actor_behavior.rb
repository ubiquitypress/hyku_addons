# frozen_string_literal: true

module HykuAddons
  module Actors
    module FileSetActorBehavior
      def attach_to_work(work, file_set_params = {})
        acquire_lock_for(work.id) do
          # Ensure we have an up-to-date copy of the members association, so that we append to the end of the list.
          work.reload unless work.new_record?

          file_set.visibility = work.visibility unless assign_visibility?(file_set_params)
          work.ordered_members << file_set
          work.representative = file_set if work.representative_id.blank?
          work.thumbnail = file_set if work.thumbnail_id.blank?
          # Save the work so the association between the work and the file_set is persisted (head_id)
          # NOTE: the work may not be valid, in which case this save doesn't do anything.
          work.save
          Hyrax.config.callback.run(:after_create_fileset, file_set, user)

          # Perform TaskMaster related filset callback
          Hyrax.config.callback.run(:task_master_after_create_fileset, file_set, user)
        end
      end
    end
  end
end
