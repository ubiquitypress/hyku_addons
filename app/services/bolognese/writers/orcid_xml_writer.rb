# frozen_string_literal: true

module Bolognese
  module Writers
    module OrcidXmlWriter
      include Bolognese::Helpers::Dates
      include Bolognese::Helpers::Writers

      # NOTE: I really don't like having to have the put_code injected here, but
      # we need to pass it in from the orcid_work instance somehow and this is the
      # best solution I have right now
      def orcid_xml(type, put_code = nil)
        root_attributes = {
          "xmlns:common" => "http://www.orcid.org/ns/common",
          "xmlns:work" => "http://www.orcid.org/ns/work",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:schemaLocation" => "http://www.orcid.org/ns/work /work-2.1.xsd "
        }
        # If we are updating, we need to add a put-code in the root attributes
        root_attributes["put-code"] = put_code if put_code.present?

        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.work(root_attributes) do
            # Hack to enable root level namespaces `work:work`
            xml.parent.namespace = xml.parent.namespace_definitions.find { |ns| ns.prefix == "work" }

            xml_writer_class.new(xml: xml, type: type, metadata: self).build
          end
        end

        builder.to_xml
      end

      # Allow us to use specific writer classes for work types that might be required to return different XML
      # The has_model attribute needs to be set properly for this to work as intended:
      #
      # input = work.attributes.merge(has_model: work.has_model.first).to_json
      # Bolognese::Readers::GenericWorkReader.new(input: input, from: "work")
      def xml_writer_class
        "Bolognese::Writers::Xml::#{meta.dig('types', 'hyrax')}Writer".constantize
      rescue NameError
        Bolognese::Writers::Xml::GenericWorkWriter
      end
    end
  end
end
