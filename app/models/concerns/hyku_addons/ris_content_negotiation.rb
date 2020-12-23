module HykuAddons
  module RisContentNegotiation
    def self.extended(document)
      document.will_export_as(:ris, "application/x-research-info-systems")
    end

    def export_as_ris
      byebug
      json = Hyrax::GenericWorkPresenter::DELEGATED_METHODS.collect {|m| [m, p.send(m)]}.to_h.merge('has_model' => p.model.model_name).to_json

      m = Bolognese::Metadata.new(input: json, from: 'ubiquity_generic_work')
      m.ris
    end
  end
end
