# frozen_string_literal: true

class Article < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:article)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = ::ArticleIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
