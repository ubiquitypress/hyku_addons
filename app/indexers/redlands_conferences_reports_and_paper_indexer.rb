# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsConferencesReportsAndPaper`
class RedlandsConferencesReportsAndPaperIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:redlands_conferences_reports_and_paper)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
