# frozen_string_literal: true

module HykuAddons
  module FunderProjectRefMultiple
    extend ActiveSupport::Concern

    included do
      property :fndr_project_ref, predicate: ::RDF::Vocab::BF2.awards do |index|
        index.as :stored_searchable
      end
    end
  end
end
