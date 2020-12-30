# Generated via
#  `rails generate hyrax:work TimeBasedMediaArticle`
class TimeBasedMediaArticle < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include Hyrax::DOI::DOIBehavior
  include Hyrax::DOI::DataCiteDOIBehavior
  include ::HykuAddons::GenericWorkOverrides

  self.json_fields = %i[funder alternative_indentifier related_indentifier]
  self.date_fields = %i[data_published data_accepted date_submitted]

  self.indexer = TimeBasedMediaArticleIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
