# frozen_string_literal: true

module Bolognese
  module Writers
    module RisWriterBehavior
      extend ActiveSupport::Concern
      DEFAULT_RESOURCE_TYPE = :GEN
      # This was taken from the legacy application and i'm unsure which of them are required.
      RESOURCE_TYPES = {
        JOUR: ["Article default Journal article", "Article Book review", "Article Data paper",
               "Article Editorial", "Article Letter to the editor", "Collection Data paper",
               "Collection Journal article", "Collection Working paper"],
        SOUND: ["Audio", "TimeBasedMedia Audio", "ExhibitionItem Audio-visual guide", "GenericWork Sound",
                "TimeBasedMedia Interview (radio, television)", "TimeBasedMedia Musical composition",
                "TimeBasedMedia Podcast", "Collection Sound"],
        BOOK: ["Book default Book", "Book", "Book Grey literature", "Book Working paper", "Collection Book"],
        DATA: ["Dataset default Dataset", "Dataset", "Dataset Numerical dataset", "Dataset Geographical dataset",
               "Collection Database", "Collection Dataset", "Collection Geographical dataset"],
        THES: ["Dissertation", "Masters Thesis", "GenericWork Dissertation",
               "ThesisOrDissertation Doctoral thesis", "ThesisOrDissertation Master's dissertation",
               "Collection Thesis (doctoral)"],
        MAP: ["Map or Cartographic Material", "GenericWork Cartographic material",
              "Collection Cartographic material"],
        CHAP: ["Part of Book", "BookContribution default Book chapter", "BookContribution Book editorial",
               "Collection Book chapter", "Collection Book editorial"],
        CONF: ["Poster", "ConferenceItem Abstract", "ConferenceItem Conference paper (published)",
               "ConferenceItem default Conference paper (unpublished)",
               "ConferenceItem Conference poster (published)", "ConferenceItem Conference poster (unpublished)",
               "ConferenceItem Lecture", "ConferenceItem Presentation", "Collection Conference paper (published)",
               "Collection Conference paper (unpublished)", "Collection Conference poster (published)",
               "Collection Conference poster (unpublished)"],
        RPRT: ["Report", "Report Policy report", "Report default Research report", "Report Technical report",
               "Collection Policy report", "Collection Research report", "Collection Technical report"],
        COMP: ["Software or Program Code", "GenericWork Software", "Collection Software", "Dataset Software"],
        VIDEO: ["Video", "TimeBasedMedia Animation", "TimeBasedMedia Video"],
        MGZN: ["Article Magazine article", "Collection Magazine article"],
        NEWS: ["Article Newspaper article", "Collection Newspaper article"],
        MUSIC: ["GenericWork Musical notation", "Collection Musical notation"],
        PAT: ["GenericWork Patent", "Collection Patent"],
        ELEC: ["GenericWork Website", "Collection Website"],
        BLOG: ["GenericWork Blog post", "Collection Blog post"]
      }.freeze

      included do
        def ris
          # raise meta.dig('editor').inspect
          {
            TY: calculate_resource_type(types),
            T1: parse_attributes(titles, content: "title", first: true),
            T2: container && container["title"],
            AU: to_ris(creators),
            DO: doi,
            ED: to_ris(meta.dig("editor")),
            AB: parse_attributes(descriptions, content: "description", first: true),
            KW: Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) }.presence,
            PY: publication_year,
            PB: publisher,
            PP: meta.dig("place_of_publication"),
            EP: container.to_h["lastPage"],
            SN: ordered_identifiers,
            JO: meta.dig("journal_title"),
            LA: meta.dig("language"),
            N1: meta.dig("add_info"),
            UR: meta.dig("official_link"),
            IS: container.to_h["issue"],
            VL: container.to_h["volume"],
            ER: ""
          }
            .compact
            .map { |k, v| v.is_a?(Array) ? v.map { |vi| "#{k}  - #{vi}" }.join("\r\n") : "#{k}  - #{v}" }
            .join("\r\n")
        end

        # Legacy code ordered the values and returned
        def ordered_identifiers
          related_identifiers
            .select { |h| h["relatedIdentifier"].present? }
            .map { |h| [h["relatedIdentifierType"], h["relatedIdentifier"]] }.to_h
            .slice('ISBN', 'ISSN', 'EISSN')
            .values.first
        end

        def calculate_resource_type(types)
          RESOURCE_TYPES.select { |_k, v| v.include?(types["resourceType"].first) }.keys.first || DEFAULT_RESOURCE_TYPE
        end
      end
    end
  end
end
