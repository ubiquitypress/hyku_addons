# frozen_string_literal: true
module HykuAddons
  module CollectionIndexerOverride
    extend ActiveSupport::Concern

    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name("account_cname", :stored_searchable)] = Site.instance.account.cname
      end
    end
  end
end
