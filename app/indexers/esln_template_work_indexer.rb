# frozen_string_literal: true

class EslnTemplateWorkIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:esln_template_work)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
