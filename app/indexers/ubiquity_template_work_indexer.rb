# frozen_string_literal: true

class UbiquityTemplateWorkIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:ubiquity_template_work)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
