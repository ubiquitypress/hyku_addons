# frozen_string_literal: true

module HykuAddons
  module AddInfoSingular
    extend ActiveSupport::Concern

    included do
      property :add_info, predicate: ::RDF::Vocab::BIBO.term(:Note), multiple: false do |index|
        index.as :stored_searchable
      end
    end
  end
end
