# frozen_string_literal: true
module HykuAddons
  module RisContentNegotiation
    def self.extended(document)
      document.will_export_as(:ris, "application/x-research-info-systems")
    end

    def export_as_ris
      json = attributes.merge.to_json
      Bolognese::Metadata.new(input: json, from: 'ubiquity_generic_work').ris
    end
  end
end
