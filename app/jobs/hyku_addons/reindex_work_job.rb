# frozen_string_literal: true
module HykuAddons
  class ReindexWorkJob < ApplicationJob
    def perform(work_id)
      ActiveFedora::Base.find(work_id).update_index
    end
  end
end
