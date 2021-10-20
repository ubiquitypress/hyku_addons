# frozen_string_literal: true
module HykuAddons
  class ReindexModelJob < ApplicationJob
    rescue_from Ldp::Gone, RSolr::Error::Http, RSolr::Error::ConnectionRefused do |exception|
      Rails.logger.debug exception.inspect
      retry_job(wait: 5.minutes)
    end

    def perform(klass, cname)
      AccountElevator.switch!(cname)

      Rails.logger.debug "=== Starting to reindex #{klass} in #{cname} ==="

      klass.constantize.reindex_everything

      Rails.logger.debug "=== Completed reindex of #{klass} in #{cname} ==="
    end
  end
end
