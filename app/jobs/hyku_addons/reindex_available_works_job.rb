# frozen_string_literal: true

# call with
# HykuAddons::ReindexAvailableWorksJob.perform_now(['repo.hyku.docker'], cname_doi_mint: ["repo.hyku.docker"] )
#
# HykuAddons::ReindexAvailableWorksJob.perform_now(['repo.hyku.docker'])

module HykuAddons
  class ReindexAvailableWorksJob < ApplicationJob
    # cnames is an array
    def perform(cnames, cname_doi_mint: [])
      @cname_doi_mint = cname_doi_mint

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
          HykuAddons::ReindexModelJob.perform_later(model_class, cname, options: { cname_doi_mint: @cname_doi_mint }) if @cname_doi_mint.include?(cname)
          HykuAddons::ReindexModelJob.perform_later(model_class, cname) unless @cname_doi_mint.include?(cname)
        end
      end
  end
end
