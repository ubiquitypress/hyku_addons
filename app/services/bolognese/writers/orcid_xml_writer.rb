# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
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
      CONTRIBUTOR_MAP = {
        "author" => ["Author"],
        "assignee" => [],
        "editor" => ["Editor"],
        "chair-or-translator" => ["Translator"],
        "co-investigator" => [],
        "co-inventor" => [],
        "graduate-student" => [],
        "other-inventor" => [],
        "principal-investigator" => [],
        "postdoctoral-researcher" => [],
        "support-staff" => ["Other"]
      }.freeze
      DEFAULT_CONTRIBUTOR_ROLE = "support-staff"

      # rubocop:disable Metrics/MethodLength
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
            # Removed for now
            # xml[:work].send("short-description", fixed_length_abstract)
            # xml[:work].send("language-code", "en") # Temp as HA doesn't deal with languages properly

            # These fields will cause multiple errors when included, no matter the work-type being used - even `other`
            # xml[:work].send("journal-title", "Work Journal Title")
            # xml[:work].url "http://test-url.com"
            # xml[:common].country "US"

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
              xml_contributors(xml)
            end
          end
        end

        builder.to_xml
      end
      # rubocop:enable Metrics/MethodLength
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
              xml_contributor_orcid(xml, find_valid_orcid(creator))
              xml_contributor_name(xml, "#{creator['givenName']} #{creator['familyName']}")
              xml_contributor_role(xml, i.zero?, "Author")
            end
          end
        end

        def xml_contributors(xml)
          contributors.each do |contributor|
            xml[:work].contributor do
              xml_contributor_orcid(xml, find_valid_orcid(contributor))
              xml_contributor_name(xml, "#{contributor['givenName']} #{contributor['familyName']}")
              xml_contributor_role(xml, false, contributor["contributorType"])
            end
          end
        end

      private

        def xml_contributor_name(xml, name)
          xml[:work].send("credit-name", name)
        end

        def xml_contributor_role(xml, primary = true, role = "Author")
          xml[:work].send("contributor-attributes") do
            xml[:work].send("contributor-sequence", primary ? "first" : "additional")

            xml[:work].send("contributor-role", orcid_role(role))
          end
        end

        def xml_contributor_orcid(xml, orcid)
          return unless orcid.present?

          xml[:common].send("contributor-orcid") do
            xml[:common].uri "https://orcid.org/#{orcid}"
            xml[:common].path orcid
            xml[:common].host "orcid.org"
          end
        end

        def find_valid_orcid(hsh)
          identifier = hsh["nameIdentifiers"]&.find { |id| id["nameIdentifierScheme"] == "orcid" }

          validate_orcid(identifier&.dig("nameIdentifier"))
        end

        def orcid_role(role)
          CONTRIBUTOR_MAP.find { |_k, v| v.include?(role) }&.first || DEFAULT_CONTRIBUTOR_ROLE
        end

        # short-description max length is 5000, and truncate uses `...` after truncation
        def fixed_length_abstract
          write_abstract.first&.truncate(4997)
        end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
