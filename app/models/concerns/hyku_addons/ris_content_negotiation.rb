# frozen_string_literal: true
module HykuAddons
  module RisContentNegotiation
    def self.extended(document)
      document.will_export_as(:ris, "application/x-research-info-systems")
    end

    def export_as_ris
      json = attributes.merge('has_model' => model_name).to_json
      Bolognese::Readers::GenericWorkReader.new(input: json, from: 'generic_work').ris
    end
  end
end
