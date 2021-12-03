# frozen_string_literal: true
module HykuAddons
  class ReindexModelJob < ApplicationJob
    queue_as :reindex

    rescue_from Hyrax::DOI::DataCiteClient::Error, Ldp::Gone, Ldp::HttpError, RSolr::Error::Http, RSolr::Error::ConnectionRefused do |exception|
      Rails.logger.debug exception.inspect
      retry_job(wait: 5.minutes)
    end

    def perform(klass, cname, limit: 25, page: 1, cname_doi_mint: [])
      # for whatever in private methods reason without assigning it to instamce variable it throws undefined local variable
      @cname_doi_mint = cname_doi_mint
      @cname = cname
      AccountElevator.switch!(cname)

      Rails.logger.debug "=== Starting to reindex #{klass} in #{cname} ==="

      offset = (page - 1) * limit

      # When the offset becomes too large, no records would be found
      works =  klass.constantize.where("title_tesim:*").limit(limit).offset(offset)

      # with calling to_a it always returns true, even when no records found
      if works.to_a.any?
        reindex_works(works)

        new_page_count = page.to_i + 1

        # Re-enqueue
        ReindexModelJob.perform_later(klass, cname, page: new_page_count)
      end

      Rails.logger.debug "=== Completed reindex of #{klass} in #{cname} ==="
    end

    private

      def reindex_works(works)
        # works.each(&:update_index)
        works.each do |work|
          mint_doi(work) if @cname_doi_mint.present? && @cname_doi_mint.include?(@cname)

          # We have temporarily replaced work.update_index with a  save to kill two birds with
          # one stone, as in re_index and also update member_of_collections_ssim to store
          # collection names instead of id caused by wrong bulkrax import
          work.save
        end
      end

      def mint_doi(work)
        return if work.doi.present?

        work.update(doi_status_when_public: "findable")
        register_doi = Hyrax::DOI::DataCiteRegistrar.new.register!(object: work)
        work.update(doi: [register_doi.identifier])
      end
  end
end
