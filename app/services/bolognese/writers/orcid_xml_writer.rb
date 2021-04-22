# frozen_string_literal: true

module Bolognese
  module Writers
    module OrcidXmlWriter
      def orcid_xml
        header = {
          "xmlns:common" => "http://www.orcid.org/ns/common",
          "xmlns:work" => "http://www.orcid.org/ns/work",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" => "http://www.orcid.org/ns/work /work-3.0.xsd "
        }

        builder = Nokogiri::XML::Builder.new { |xml|
          xml.root(header) do
            xml.tenderlove
          end
        }
        builder.to_xml

      end
    end
  end
end
