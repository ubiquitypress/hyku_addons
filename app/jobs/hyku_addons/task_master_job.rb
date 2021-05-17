# frozen_string_literal: true

module HykuAddons
  class TaskMasterWorkJob < ApplicationJob
    def perform(work_id)
      HykuAddons::TaskMasterWorkService.new(work_id).perform
    end
  end
end

