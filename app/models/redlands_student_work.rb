# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsStudentWork`
class RedlandsStudentWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:redlands_student_work)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = RedlandsStudentWorkIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
