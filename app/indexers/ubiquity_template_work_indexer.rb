# frozen_string_literal: true

class UbiquityTemplateWorkIndexer < Hyrax::WorkIndexer
  # include Hyrax::Indexer(:ubiquity_template_work)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata

  def generate_solr_document
    schema = Hyrax::SimpleSchemaLoader.new.index_rules_for(schema: :ubiquity_template_work)

    super.tap do |solr_doc|
      Array(schema).each do |index_key, method|
        next if solr_doc[index_key].present?

        solr_doc[index_key.to_s] = object.try(method)
      end
    end
  end
end
