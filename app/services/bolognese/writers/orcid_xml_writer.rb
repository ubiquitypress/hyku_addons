# frozen_string_literal: true

module Bolognese
  module Writers
    module OrcidXmlWriter

      ROOT_ATTRIBUTES = {
        "xmlns:common" => "http://www.orcid.org/ns/common",
        "xmlns:work" => "http://www.orcid.org/ns/work",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation" => "http://www.orcid.org/ns/work /work-2.1.xsd "
      }.freeze

      def orcid_xml
        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.work(ROOT_ATTRIBUTES) do
            # Hack to enable root level namespaces `work:work`
            xml.parent.namespace = xml.parent.namespace_definitions.find { |ns| ns.prefix == "work" }

            xml[:work].title do
              xml[:common].title "Testing title"
            end

            xml[:work].type "Work type"
            xml[:common].send("external-ids") do
              xml[:common].send("external-id") do
                xml[:common].send("external-id-type", "doi")
                xml[:common].send("external-id-value", "10.1087/20120404")
                xml[:common].send("external-id-url", "https://doi.org/10.1087/20120404")
                xml[:common].send("external-id-relationship", "self")
              end
            end
          end
        end

        builder.to_xml
      end
    end
  end
end
