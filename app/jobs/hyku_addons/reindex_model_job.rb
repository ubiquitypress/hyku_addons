# frozen_string_literal: true
module HykuAddons
  class ReindexModelJob < ApplicationJob
    queue_as :reindex

    rescue_from Ldp::Gone, Ldp::HttpError, RSolr::Error::Http, RSolr::Error::ConnectionRefused do |exception|
      Rails.logger.debug exception.inspect
      retry_job(wait: 5.minutes)
    end

    def perform(klass, cname, limit: 35, page: 1)
      AccountElevator.switch!(cname)

      Rails.logger.debug "=== Starting to reindex #{klass} in #{cname} ==="

      offset = (page - 1) * limit
      # When the offset becomes too large, no records would be found
      works =  klass.constantize.where("title_tesim:*").limit(limit).offset(offset)

      # with calling to_a it always returns true, even when no records found
      if works.to_a.any?
        reindex_works(works)

        # increment page number
        new_page_count = page.to_i + 1

        # re-enqueue
        ReindexModelJob.perform_later(klass, cname, limit: 1, page: new_page_count)
      end

      Rails.logger.debug "=== Completed reindex of #{klass} in #{cname} ==="
    end

    private

      def reindex_works(works)
        works.each(&:update_index)
      end
  end
end
