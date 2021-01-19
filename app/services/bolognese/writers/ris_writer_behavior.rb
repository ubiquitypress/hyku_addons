# frozen_string_literal: true

module Bolognese
  module Writers
    module RisWriterBehavior
      extend ActiveSupport::Concern

      included do
        def ris
          {
            "TY" => types["ris"],
            "T1" => parse_attributes(titles, content: "title", first: true),
            "T2" => container && container["title"],
            "AU" => to_ris(creators),
            "DO" => doi,
            "ED" => meta.dig("editor"),
            "AB" => parse_attributes(descriptions, content: "description", first: true),
            "KW" => Array.wrap(subjects).map { |k| parse_attributes(k, content: "subject", first: true) }.presence,
            "PY" => publication_year,
            "PB" => publisher,
            "PP" => meta.dig("place_of_publication"),
            "EP" => container.to_h["lastPage"],
            "SN" => sort_related_identifiers,
            "JO" => meta.dig("journal_title"),
            "LA" => meta.dig("language"),
            "N1" => meta.dig("add_info"),
            "UR" => meta.dig("official_link"),
            "IS" => container.to_h["issue"],
            "VL" => container.to_h["volume"],
            "ER" => ""
          }.compact.map { |k, v| v.is_a?(Array) ? v.map { |vi| "#{k}  - #{vi}" }.join("\r\n") : "#{k}  - #{v}" }.join("\r\n")
        end

        # Legacy code ordered the values and returned
        def sort_related_identifiers
          related_identifiers
            .select { |h| h["relatedIdentifier"].present? }
            .map { |h| [h["relatedIdentifierType"], h["relatedIdentifier"]] }.to_h
            .slice(*%w[ISBN ISSN EISSN])
            .values.first
        end
      end

    end
  end
end
