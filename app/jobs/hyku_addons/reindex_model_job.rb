# frozen_string_literal: true
module HykuAddons
  class ReindexModelJob < ApplicationJob
    def perform(klass, cname)
      AccountElevator.switch!(cname)

      Rails.logger.debug "=== Starting to reindex #{klass} in #{cname} ==="

      klass.constantize.reindex_everything

      Rails.logger.debug "=== Completed reindex of #{klass} in #{cname} ==="
    end
  end
end
