module HykuAddons
  module RisContentNegotiation
    def self.extended(document)
      document.will_export_as(:ris, "application/x-research-info-systems")
    end

    def export_as_ris
      Hyrax::GenericWorkPresenter.new(self, nil, nil).export_as_ris
    end
  end
end
