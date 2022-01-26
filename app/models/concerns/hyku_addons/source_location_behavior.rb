# frozen_string_literal: true

# The `source_identifier` is required for a work to be importable by Bulkrax
module HykuAddons
  module SourceLocationBehavior
    extend ActiveSupport::Concern

    included do
      property :source_identifier, predicate: ::RDF::Vocab::PROV.wasDerivedFrom, multiple: false do |index|
        index.as :stored_searchable
      end
    end
  end
end

