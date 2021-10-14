# frozen_string_literal: true

module HykuAddons
  module AddCnameToWorkAndCollectionMetadata
    extend ActiveSupport::Concern

    included do
      property :work_tenant_cname, predicate: ::RDF::Vocab::FOAF.account, multiple: false do |index|
        index.as :stored_searchable
      end
    end
  end
end
