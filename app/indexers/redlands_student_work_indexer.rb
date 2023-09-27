# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsStudentWork`
class RedlandsStudentWorkIndexer < Hyrax::WorkIndexer
  include Hyrax::Indexer(:redlands_student_work)
  include Hyrax::IndexesBasicMetadata
  include Hyrax::IndexesLinkedMetadata
end
