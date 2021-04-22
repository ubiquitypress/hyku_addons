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

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/BlockLength
      def orcid_xml
        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.work(ROOT_ATTRIBUTES) do
            # Hack to enable root level namespaces `work:work`
            xml.parent.namespace = xml.parent.namespace_definitions.find { |ns| ns.prefix == "work" }

            xml[:work].title do
              xml[:common].title "Work title"
              xml[:common].subtitle = "Work Alt title"
            end

            xml[:work].type "Work type"
            xml[:work].send("journal-title", "Work Journal Title")
            xml[:work].send("short-description", "The short description for the work")
            xml[:work].url "http://test-url.com"

            xml[:common].country "US"
            xml[:common].send("language-code", "en")

            xml[:common].send("publication-date") do
              xml[:common].year "2021"
              xml[:common].month "10"
              xml[:common].day "01"
            end

            xml[:common].send("external-ids") do
              xml[:common].send("external-id") do
                xml[:common].send("external-id-type", "doi")
                xml[:common].send("external-id-value", "10.1087/20120404")
                xml[:common].send("external-id-url", "https://doi.org/10.1087/20120404")
                xml[:common].send("external-id-relationship", "self")
              end
            end

            xml[:work].contributors do
              xml[:work].contributor do
                xml[:common].send("contributor-orcid") do
                  xml[:common].uri "https://orcid.org/0000-0001-5109-3700"
                  xml[:common].path "0000-0001-5109-3700"
                  xml[:common].host "orcid.org"
                end

                xml[:work].send("credit-name", "John Smith")
                xml[:work].send("contributor-attributes") do
                  xml[:work].send("contributor-sequence", "first")
                  xml[:work].send("contributor-role", "author")
                end
              end
            end

          end
        end

        builder.to_xml
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/BlockLength
    end
  end
end
