# frozen_string_literal: true
module HykuAddons
  class PostMigrationFixWorkJob < ApplicationJob
    def perform(work_id, values, work_visibility)
      work = ActiveFedora::Base.find(work_id)
      thumbnail_id = nil
      representative_id = nil
      need_to_save_work = false
      values.flatten.each do |v|
        fs = work.file_sets.find { |f| f.label == v[:label] }
        thumbnail_id = fs.id if v[:thumbnail]
        representative_id = fs.id if v[:representative]
        need_to_save = false
        if fs.visibility != v[:visibility]
          # puts "Updating the visibility of #{fs.id} to #{v[:visibility]}"
          fs.visibility = v[:visibility]
          need_to_save = true
        end
        if v[:embargo_release_date].present? && fs.embargo_release_date != v[:embargo_release_date]
          # puts "Updating embargo details of #{fs.id}"
          fs.embargo_release_date = DateTime.parse(v[:embargo_release_date])
          fs.visibility_during_embargo = v[:visibility_during_embargo]
          fs.visibility_after_embargo = v[:visibility_after_embargo]
          need_to_save = true
        end
        if fs.description != v[:description]
          # puts "Updating the description of #{fs.id} to #{v[:description]}"
          fs.description = v[:description]
          need_to_save = true
        end
        if fs.date_uploaded.to_s != v[:date_uploaded]
          # puts "Updating the date uploaded of #{fs.id} to #{v[:date_uploaded]}"
          fs.date_uploaded = DateTime.parse(v[:date_uploaded])
          need_to_save = true
        end
        fs.save! if need_to_save
      end
      if thumbnail_id.present? && work.thumbnail_id != thumbnail_id
        # puts "Updating #{work.id}'s thumbnail_id"
        work.thumbnail_id = thumbnail_id
        need_to_save_work = true
      end
      if representative_id.present? && work.representative_id != representative_id
        # puts "Updating #{work.id}'s representative_id"
        work.representative_id = representative_id
        need_to_save_work = true
      end
      if work.visibility != work_visibility
        # puts "Updating #{work.id}'s visibility to #{work_visibility}"
        work.visibility = work_visibility
        need_to_save_work = true
      end
      work.save! if need_to_save_work
    end
  end
end
