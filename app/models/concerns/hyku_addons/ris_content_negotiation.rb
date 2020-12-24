module HykuAddons
  module RisContentNegotiation
    def self.extended(document)
      document.will_export_as(:ris, "application/x-research-info-systems")
    end

    def export_as_ris
      json = Hyrax::GenericWorkPresenter::DELEGATED_METHODS.collect do |m|
        [m, p.send(m)]
      end.to_h.merge('has_model' => p.model.model_name).to_json

      m = Bolognese::Metadata.new(input: json, from: 'ubiquity_generic_work')
      m.ris
    end

    # def export_as_ttl
    #   clean_graph.dump(:ttl)
    # end

    private

    def clean_graph
      @clean_graph ||= clean_graph_repository.find(id)
    end

    def clean_graph_repository
      CleanGraphRepository.new(connection)
    end

    def connection
      ActiveFedora.fedora.clean_connection
end
