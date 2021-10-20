# frozen_string_literal: true
module HykuAddons
  class ReindexAvailableWorksJob < ApplicationJob
    def perform(array_of_cname)
      array_of_cname.each do |cname|
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
          HykuAddons::ReindexModelJob.perform_now(model_class, cname) if contains_work
        end
      end
  end
end
