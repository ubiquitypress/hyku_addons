# frozen_string_literal: true

class LabNotebookIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:lab_notebook)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end