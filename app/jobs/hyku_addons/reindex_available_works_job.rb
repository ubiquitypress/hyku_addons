# frozen_string_literal: true
module HykuAddons
  class ReindexAvailableWorksJob < ApplicationJob
    rescue_from Ldp::Gone, RSolr::Error::Http, RSolr::Error::ConnectionRefused do |exception|
      Rails.logger.debug exception.inspect
      retry_job(wait: 5.minutes)
    end

    # cnames is an array
    def perform(cnames)
      cnames.each do |name|
        cname = cnames.delete(name)
        fetch_work_save_cname(cname)
      end
    end

    private

      def fetch_work_save_cname(cname)
        AccountElevator.switch!(cname)
        available_works = Site.first.available_works | ['Collection']

        available_works.each do |model_class|
          klass = model_class.constantize
          contains_work = klass.count.positive?

          Rails.logger.debug "==== Queue ReindexModelJob for #{klass} ===" if contains_work
          HykuAddons::ReindexModelJob.perform_later(model_class, cname) if contains_work
        end
      end
  end
end
