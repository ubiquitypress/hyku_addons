# frozen_string_literal: true

module HykuAddons
  class ToggleDisplayProfileJob < ApplicationJob
    def perform(email, display_profile)
      query_string = "generic_type_sim:Work AND (creator_tesim:\"*#{email}*\")"
      works = ActiveFedora::SolrService.get(query_string, rows: 1_000_000).dig("response", "docs")
                                       .map { |doc| ActiveFedora::SolrHit.new(doc).reify }

      works.each do |work|
        creator_hash = JSON.parse(work["creator"].first)
        creator_hash.map! do |creator|
          if creator["creator_institutional_email"] == email
            creator["creator_profile_visibility"] = display_profile ? "open" : "closed"
          end

          creator
        end

        work.update!(creator: Array.wrap(creator_hash.to_json))
      end
    end
  end
end
