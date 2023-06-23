# frozen_string_literal: true

class DataManagementPlan < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Hyrax::DOI::DataCiteDOIBehavior

  include HykuAddons::Schema::WorkBase
  include Hyrax::Schema(:data_management_plan)

  # Included after other field definitions
  include Hyrax::BasicMetadata

  self.indexer = DataManagementPlanIndexer

  validates :title, presence: { message: "Your work must have a title." }
  def doi_registrar_opts
    {}
  end
end