# frozen_string_literal: true
module HykuAddons
  module ImportBehavior
    extend ActiveSupport::Concern

    included do
      property :bulk, predicate: ::RDF::Vocab::OGC.boolean_str, multiple: false do |index|
        index.as :stored_searchable
      end
    end
  end
end
