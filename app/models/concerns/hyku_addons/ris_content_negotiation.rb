# frozen_string_literal: true
module HykuAddons
  module RisContentNegotiation
    def self.extended(document)
      document.will_export_as(:ris, "application/x-research-info-systems")
    end

    def export_as_ris
      json = attributes.merge("has_model" => model_name).to_json

      # NOTE:
      # Im not super happy with having 'work' here as it isn't dynamic, but requires that the reader
      # classes need to override the parent `read_work` method. However, because thi is inherited
      # from and not injected into the parent, this doesn't techincaly cause an issue.
      meta_reader_class.new(input: json, from: "work").ris
    end
  end
end
