# frozen_string_literal: true

module HykuAddons
  class TaskMasterJob < ApplicationJob
    def perform(work_id)
      HykuAddons::TaskMasterService.new(work_id).perform
    end
  end
end

