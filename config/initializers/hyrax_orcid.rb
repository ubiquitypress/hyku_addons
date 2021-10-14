# frozen_string_literal: true

# Hyrax Orcid configuration
Hyrax::Orcid.configure do |config|
  config.bolognese = {
    # The work reader method, excluding the _reader suffix
    reader_method: "hyku_addons_work",
    # The XML builder class that provides the XML body which is sent to Orcid
    xml_builder_class_name: "Bolognese::Writers::Orcid::HykuAddonsXmlBuilder"
  }

  # HykuAddons doesn't need either of these actors/pipelines as they are already implemented or redundant
  config.hyrax_json_actor = nil
  config.blacklight_pipeline_actor = nil
  config.presenter_behavior = nil
  config.active_job_type = :perform_later

  # Override the work types as we don't need either of the Orcid Behaviors in HykuAddons
  config.work_types = []
end
