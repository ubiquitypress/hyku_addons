# frozen_string_literal: true

# Hyrax Orcid configuration
Hyrax::Orcid.configure do |config|
  config.bolognese = {
    # The work reader method, excluding the _reader suffix
    reader_method: "hyku_addons_work",
    # The XML builder class that provides the XML body which is sent to Orcid
    xml_builder_class_name: "Bolognese::Writers::Orcid::HykuAddonsXmlBuilder"
  }
end
