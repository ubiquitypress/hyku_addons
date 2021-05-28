# frozen_string_literal: true

module Bolognese
  module Writers
    module OrcidXmlWriter
      include Bolognese::Helpers::Dates
      include Bolognese::Helpers::Writers

      ROOT_ATTRIBUTES = {
        "xmlns:common" => "http://www.orcid.org/ns/common",
        "xmlns:work" => "http://www.orcid.org/ns/work",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation" => "http://www.orcid.org/ns/work /work-2.1.xsd "
      }.freeze

      def orcid_xml(type)
        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.work(ROOT_ATTRIBUTES) do
            # Hack to enable root level namespaces `work:work`
            xml.parent.namespace = xml.parent.namespace_definitions.find { |ns| ns.prefix == "work" }

            xml_writer_class.new(xml: xml, type: type, metadata: self).build
          end
        end

        builder.to_xml
      end

      # Allow us to use specific writer classes for work types that might be required to return different XML
      def xml_writer_class
        "Bolognese::Writers::Xml::#{meta.dig('types', 'hyrax')}Writer".constantize
      rescue NameError
        Bolognese::Writers::Xml::GenericWorkWriter
      end
    end
  end
end
