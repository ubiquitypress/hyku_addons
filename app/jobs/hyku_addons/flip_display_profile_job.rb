# frozen_string_literal: true

module HykuAddons
  class FlipDisplayProfileJob < ApplicationJob

    def perform(email, display_profile)
      query_string = "(creator_tesim:\"*#{email}*\")"
      works = ActiveFedora::SolrService.get(query_string, rows: 1_000_000)["response"]["docs"].map { |doc| ActiveFedora::SolrHit.new(doc).reify }
      works.each do |work|
        creators = JSON.parse(work["creator"].first)
        creators.map do |creator|
          creator["display_creator_profile"] = display_profile if creator["creator_institutional_email"] == email
        end
        updated_creators = Array.wrap(creators.to_json)
        work.update!(creator: Array.wrap(updated_creators))
      end
    end
  end
end
