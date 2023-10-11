# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificArticle`
class PacificArticle < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:pacific_article)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = PacificArticleIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
