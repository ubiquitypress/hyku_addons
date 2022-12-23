# frozen_string_literal: true

class EslnTemplateWork < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:esln_template_work)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = EslnTemplateWorkIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end
