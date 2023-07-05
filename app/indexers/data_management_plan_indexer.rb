# frozen_string_literal: true

class DataManagementPlanIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:data_management_plan)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end