# frozen_string_literal: true

#  use_work_ids an array is just for testing a few ids
#  HykuAddons::ReindexModelJob.perform_now("GenericWork", "repo.hyku.docker", limit: 1, options: { cname_doi_mint: ["repo.hyku.docker"], use_work_ids: ["15b3c16b-8183-4d2a-86ef-d144176fa0c8"]} )
#  HykuAddons::ReindexAvailableWorksJob.perform_later(["repo.hyku.docker"], options: { cname_doi_mint: ["repo.hyku.docker"]} )

module HykuAddons
  class ReindexModelJob < ApplicationJob
    rescue_from Hyrax::DOI::DataCiteClient::Error, Ldp::Gone, Ldp::HttpError, RSolr::Error::Http, RSolr::Error::ConnectionRefused do |exception|
      Rails.logger.debug exception.inspect
      retry_job(wait: 5.minutes)
    end

    # rubocop:disable Metrics/MethodLength
    def perform(klass, cname, limit: 25, page: 1, options: {})
      options ||= options || { cname_doi_mint: [], use_work_ids: [] }
      # for whatever in private methods reason without assigning it to instamce variable it throws undefined local variable
      @cname_doi_mint = options[:cname_doi_mint]
      @use_work_ids = options[:use_work_ids]
      @cname = cname
      @limit = limit
      @page = page
      @klass = klass
      AccountElevator.switch!(cname)
      offset = (page - 1) * @limit
      work_class = klass.constantize

      if @use_work_ids.present?
        fetch_work_using_ids(work_class)
      else
        reindex_and_mint_work(work_class, offset)
      end
    end

    private

      def mint_doi(work)
        return if work.doi.present?

        Rails.logger.debug "=== about to mint doi for #{work.title} ==== "
        work.update(doi_status_when_public: "findable")
        register_doi = Hyrax::DOI::DataCiteRegistrar.new.register!(object: work)
        work.update(doi: [register_doi.identifier])
      end

      def fetch_work_using_ids(klass)
        @use_work_ids.map do |id|
          work = klass.find(id)
          Rails.logger.debug "=== updating index with #{id}for #{work&.title&.to_a&.first} ===="
          mint_doi(work) if @cname_doi_mint.present? && @cname_doi_mint.include?(@cname)
          work.save
        end
      end

      def reindex_works(works)
        works.each do |work|
          mint_doi(work) if @cname_doi_mint.present? && @cname_doi_mint.include?(@cname)

          # We have temporarily replaced work.update_index with a  save to kill two birds with
          # one stone, as in re_index and also update member_of_collections_ssim to store
          # collection names instead of id caused by wrong bulkrax import
          work.save
        end
      end

      # When the offset becomes too large, no records would be found
      def reindex_and_mint_work(work_class, offset)
        works = work_class.where("title_tesim:*").limit(@limit).offset(offset)&.to_a
        return unless works&.any?

        Rails.logger.debug "=== Starting to reindex #{@klass} in #{@cname} ==="

        # with calling to_a it always returns true, even when no records found
        reindex_works(works)

        # Re-enqueue
        ReindexModelJob.perform_later(@klass, @cname, @limit, page: @page.to_i + 1, cname_doi_mint: @cname_doi_mint)
        Rails.logger.debug "=== Completed reindex of #{@klass} in #{@cname} ==="
      end
  end
end
