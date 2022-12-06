# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work UnaArticle`
class UnaArticle < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:una_article)
  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Hyrax::BasicMetadata

  self.indexer = UnaArticleIndexer

  validates :title, presence: { message: "Your work must have a title." }

  def doi_registrar_opts
    {}
  end
end
