# frozen_string_literal: true

module Bolognese
  module Writers
    module OrcidXmlWriter
      include Bolognese::Helpers::Dates
      include Bolognese::Helpers::Writers

      PERMITTED_EXTERNAL_IDENTIFIERS = %w[issn isbn].freeze

      ROOT_ATTRIBUTES = {
        "xmlns:common" => "http://www.orcid.org/ns/common",
        "xmlns:work" => "http://www.orcid.org/ns/work",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation" => "http://www.orcid.org/ns/work /work-2.1.xsd "
      }.freeze

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/BlockLength
      # rubocop:disable Metrics/AbcSize
      def orcid_xml(type)
        builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
          xml.work(ROOT_ATTRIBUTES) do
            # Hack to enable root level namespaces `work:work`
            xml.parent.namespace = xml.parent.namespace_definitions.find { |ns| ns.prefix == "work" }

            xml[:work].title do
              xml[:common].title write_title.first
              xml[:common].subtitle write_alt_title.first
            end

            xml[:work].type type

            # These fields will cause multiple errors when included, no matter the work-type being used - even `other`
            # xml[:work].send("journal-title", "Work Journal Title")
            # xml[:work].send('short-description", "The short description for the work")
            # xml[:work].url "http://test-url.com"
            # xml[:common].country "US"
            # xml[:common].send("language-code", "en")

            xml[:common].send("publication-date") do
              %i[year month day].each do |int|
                xml[:common].send(int, date_published.first["date_published_#{int}"])
              end
            end

            # Full list of external-id-type: https://pub.orcid.org/v3.0/identifiers
            xml[:common].send("external-ids") do
              xml_external_doi(xml)
              xml_external_identifiers(xml)
            end

            xml[:work].contributors do
              xml_creators(xml)
            end
          end
        end

        builder.to_xml
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/BlockLength
      # rubocop:enable Metrics/AbcSize

      protected

        def xml_external_doi(xml)
          return if meta["doi"].blank?

          xml[:common].send("external-id") do
            xml[:common].send("external-id-type", "doi")
            xml[:common].send("external-id-value", meta["doi"].gsub("https://doi.org/", ""))
            xml[:common].send("external-id-url", meta["doi"])
            xml[:common].send("external-id-relationship", "self")
          end
        end

        def xml_external_identifiers(xml)
          PERMITTED_EXTERNAL_IDENTIFIERS.each do |item|
            next unless (value = meta.dig(item)).present?

            xml[:common].send("external-id") do
              xml[:common].send("external-id-type", item)
              xml[:common].send("external-id-value", value)
              xml[:common].send("external-id-relationship", "self")
            end
          end
        end

        def xml_creators(xml)
          creators.each_with_index do |creator, i|
            xml[:work].contributor do
              if (orcid = find_valid_orcid(creator)).present?
                xml[:common].send("contributor-orcid") do
                  xml[:common].uri "https://orcid.org/#{orcid}"
                  xml[:common].path orcid
                  xml[:common].host "orcid.org"
                end
              end

              xml[:work].send("credit-name", "#{creator['givenName']} #{creator['familyName']}")

              xml[:work].send("contributor-attributes") do
                xml[:work].send("contributor-sequence", i.zero? ? "first" : "additional")
                xml[:work].send("contributor-role", "author")
              end
            end
          end
        end

        def find_valid_orcid(hsh)
          identifier = hsh["nameIdentifiers"]&.find { |id| id["nameIdentifierScheme"] == "orcid" }

          validate_orcid(identifier&.dig("nameIdentifier"))
        end
    end
  end
end
