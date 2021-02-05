# frozen_string_literal: true

module Bolognese
  module Writers
    module RisWriterBehavior
      extend ActiveSupport::Concern
      DEFAULT_RESOURCE_TYPE = :GEN
      RIS_DELIMITER = "\r\n"

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
          hash = {
            TY: calculate_resource_type(types),
            T1: parse_attributes(titles, content: "title", first: true),
            T2: secondary_titles,
            AU: to_ris(creators),
            DO: doi,
            ED: to_ris(meta.dig("editor")),
            AB: parse_attributes(descriptions, content: "description", first: true),
            KW: Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) }.presence,
            DA: meta.dig('dates').find { |date| date["dateType"] == "Issued" }&.dig("date"),
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
            SP: container.to_h["pagination"],
            ER: ""
          }

          expand_nested_and_prepare(hash)
        end

        # Expand nested arrays, remove any blank entries and expand into a RIS formatted string
        def expand_nested_and_prepare(hash)
          hash
            .compact
            .map do |k, v|
              if v.is_a?(Array)
                v.map { |vi| "#{k}  - #{vi}" if vi.present? }.compact.join(RIS_DELIMITER)
              else
                "#{k}  - #{v}"
              end
            end.join(RIS_DELIMITER)
        end

        def secondary_titles
          Array.wrap(parse_attributes(meta["alt_title"])) + Array.wrap(parse_attributes(meta['book_title']))
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
