# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsChaptersAndBookSection`
class RedlandsChaptersAndBookSection < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:redlands_chapters_and_book_section)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = RedlandsChaptersAndBookSectionIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
