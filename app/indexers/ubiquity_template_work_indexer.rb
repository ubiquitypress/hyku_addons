# frozen_string_literal: true

class UbiquityTemplateWorkIndexer < Hyrax::WorkIndexer
  # include Hyrax::Indexer(:ubiquity_template_work)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata

  # TODO: Get this working here and then move to the Indexer
  def generate_solr_document
    schema = Hyrax::SimpleSchemaLoader.new.index_rules_for(schema: :ubiquity_template_work)

    super.tap do |solr_doc|
      Array(schema).each do |index_key, method|
        solr_doc[index_key.to_s] = object.try(method)
      end
    end
  end
end
