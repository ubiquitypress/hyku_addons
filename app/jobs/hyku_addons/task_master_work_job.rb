# frozen_string_literal: true

module HykuAddons
  class TaskMasterWorkJob < ApplicationJob
    def perform(work_id, options = {})
      HykuAddons::TaskMasterWorkService.new(work_id, options).perform
    end
  end
end

