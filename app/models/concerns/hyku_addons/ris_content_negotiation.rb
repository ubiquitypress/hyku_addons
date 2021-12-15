# frozen_string_literal: true

# SCOPE:
# We are currently inside the Solr document
module HykuAddons
  module RisContentNegotiation
    def self.extended(document)
      document.will_export_as(:ris, "application/x-research-info-systems")
    end

    def export_as_ris
      json = attributes.merge("has_model" => to_model.model_name.name).to_json

      ::Bolognese::Metadata.new(input: json, from: "hyku_addons_work").ris
    end
  end
end
