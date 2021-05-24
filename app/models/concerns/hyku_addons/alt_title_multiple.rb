# frozen_string_literal: true

module HykuAddons
  module AltTitleMultiple
    extend ActiveSupport::Concern

    included do
      property :alt_title, predicate: ::RDF::Vocab::DC.alternative, multiple: true do |index|
        index.as :stored_searchable
      end
    end
  end
end
