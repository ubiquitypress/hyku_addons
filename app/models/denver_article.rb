# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverArticle`
class DenverArticle < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:denver_article)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = DenverArticleIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
