# frozen_string_literal: true
module HykuAddons
  class ReindexAvailableWorksJob < ApplicationJob
    # cnames is an array
    def perform(cnames)
      cnames.each do |name|
        cname = cnames.delete(name)
        reindex(cname)
      end
    end

    private

      def reindex(cname)
        AccountElevator.switch!(cname)
        available_works = Site.first.available_works | ['Collection']

        available_works.each do |model_class|
          klass = model_class.constantize

          next unless klass.count.positive?

          Rails.logger.debug "==== Queue ReindexModelJob for #{klass} ==="
          HykuAddons::ReindexModelJob.perform_later(model_class, cname)
        end
      end
  end
end
