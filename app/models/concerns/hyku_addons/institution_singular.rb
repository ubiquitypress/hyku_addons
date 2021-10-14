# frozen_string_literal: true

module HykuAddons
  module InstitutionSingular
    extend ActiveSupport::Concern

    included do
      property :institution, predicate: ::RDF::Vocab::ORG.organization, multiple: false do |index|
        index.as :stored_searchable, :facetable
      end
    end
  end
end
