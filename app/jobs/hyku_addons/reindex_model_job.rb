# frozen_string_literal: true

#  use_work_ids an array is just for testing a few ids
#  HykuAddons::ReindexModelJob.perform_now("GenericWork", "repo.hyku.docker", limit: 1, options: { cname_doi_mint: ["repo.hyku.docker"], use_work_ids: ["15b3c16b-8183-4d2a-86ef-d144176fa0c8"]} )
#  HykuAddons::ReindexAvailableWorksJob.perform_later(["repo.hyku.docker"], options: { cname_doi_mint: ["repo.hyku.docker"]} )

module HykuAddons
  class ReindexModelJob < ApplicationJob
    rescue_from Hyrax::DOI::DataCiteClient::Error, Ldp::Gone, Ldp::HttpError, RSolr::Error::Http, RSolr::Error::ConnectionRefused, Faraday::ConnectionFailed do |exception|
      Rails.logger.debug exception.inspect
    end
    def perform(klass, cname, limit: 25, page: 1, options: {})
      @options = options.presence || { cname_doi_mint: [], use_work_ids: [] }
      # for whatever in private methods reason without assigning it to instamce variable it throws undefined local variable
      @cname_doi_mint = @options[:cname_doi_mint]
      @use_work_ids = @options[:use_work_ids]
      @cname = cname
      @limit = limit
      @page = page
      @klass = klass
      AccountElevator.switch!(cname)
      @offset = (page - 1) * @limit

      if @use_work_ids.present?
        fetch_work_using_ids
      else
        reindex_and_mint_work
      end
    end

    private

      def works
        return unless @klass

        work_class.where("title_tesim:*").limit(@limit).offset(@offset)&.to_a
      end

      def work_class
        return unless @klass

        @klass.constantize
      end

      def mint_doi(work)
        return unless can_mint_for?(work)

        Rails.logger.debug "=== about to mint doi for #{work.title} ==== "

        work.update(doi_status_when_public: "findable")
        register_doi = Hyrax::DOI::DataCiteRegistrar.new.register!(object: work)
        work.update(doi: [register_doi.identifier])
      end

      def can_mint_for?(work)
        state = workflow_state(work)

        work.creator.present? && work.doi.blank? && work.visibility == "open" && ["deposited", nil].include?(state&.workflow_state_name)
      end

      def workflow_state(work)
        @_workflow_state ||= Sipity::Entity.find_by(proxy_for_global_id: "gid://hyku/#{work.class}/#{work.id}")
      end

      def fetch_work_using_ids
        @use_work_ids.map do |id|
          work = work_class.find(id)
          Rails.logger.debug "=== updating index with #{id}for #{work&.title&.to_a&.first} ===="
          mint_doi(work) if @cname_doi_mint.present? && @cname_doi_mint.include?(@cname)
          work.save
        end
      end

      def reindex_works
        works.each do |work|
          mint_doi(work) if @cname_doi_mint.present? && @cname_doi_mint.include?(@cname)

          # We have temporarily replaced work.update_index with a  save to kill two birds with
          # one stone, as in re_index and also update member_of_collections_ssim to store
          # collection names instead of id caused by wrong bulkrax import
          work.save
        end
      end

      # When the offset becomes too large, no records would be found
      def reindex_and_mint_work
        return unless works&.any?

        Rails.logger.debug "=== Starting to reindex #{@klass} in #{@cname} ==="

        # with calling to_a it always returns true, even when no records found
        reindex_works

        # Re-enqueue
        ReindexModelJob.perform_later(@klass, @cname, limit: @limit, page: @page.to_i + 1, options: @options)
        Rails.logger.debug "=== Completed reindex of #{@klass} in #{@cname} ==="
      end

      # Override import mode
      def total_collection_entries
        return 0 unless works || @use_work_ids

        if @use_work_ids
          @use_work_ids.count
        else
          works.count
        end
      end
  end
end
