# frozen_string_literal: true
module Bolognese
  module Writers
    module Orcid
      class HykuAddonsXmlBuilder < HyraxXmlBuilder
        # Fields guide:
        # https://github.com/ORCID/ORCID-Source/blob/master/orcid-api-web/tutorial/works.md#work-fields
        # rubocop:disable Metrics/MethodLength
        def build
          @xml[:work].title do
            @xml[:common].title @metadata.titles.first.dig("title")

            xml_subtitle
          end

          xml_short_description
          xml_work_type
          xml_date_published

          # NOTE: A full list of external-id-type: https://pub.orcid.org/v2.1/identifiers
          @xml[:common].send("external-ids") do
            xml_internal_identifier
            xml_external_doi
            xml_external_identifiers
          end

          @xml[:work].contributors do
            xml_creators
            xml_contributors
          end
        end
        # rubocop:enable Metrics/MethodLength

        protected

          def xml_subtitle
            # Using `.first` isn't a great solution because the alt_title
            # entries could be returned in a non idiomatic order
            subtitle = (@metadata.meta.dig("alt_title") || []).reject(&:blank?).first

            return if subtitle.blank?

            @xml[:common].subtitle subtitle
          end

          def xml_short_description
            description = @metadata.descriptions&.dig("description") || ""

            # The maximum length of this field is 5000 and truncate appends an ellipsis
            @xml[:work].send("short-description", description.truncate(4997))
          end

          def xml_date_published
            return if published_date.blank?

            @xml[:common].send("publication-date") do
              %i[year month day].each do |interval|
                @xml[:common].send(interval, published_date.send(interval))
              end
            end
          end

          def xml_creators
            return if (creators = @metadata.meta["creators"]&.reject(&:blank?)).blank?

            creators.each_with_index do |creator, i|
              @xml[:work].contributor do
                xml_contributor_orcid(find_valid_orcid(creator))
                xml_contributor_name("#{creator.dig('givenName')} #{creator.dig('familyName')}")
                xml_contributor_role(i.zero?, "Author")
              end
            end
          end

          def xml_contributors
            return if (contributors = @metadata.meta["contributors"]&.reject(&:blank?)).blank?

            contributors.each do |contributor|
              @xml[:work].contributor do
                xml_contributor_orcid(find_valid_orcid(contributor))
                xml_contributor_name("#{contributor.dig('givenName')} #{contributor.dig('familyName')}")
                xml_contributor_role(false, contributor["contributorType"])
              end
            end
          end

          def published_date
            return unless (date_string = @metadata.meta.dig("date_published")).present?

            # The date can be parsed if its "yyyy-m-d" and "yyyy" but not "yyyy-m"
            # so if we have just a year and month, append a day sting.
            date_string << "-1" if date_string.match?(/^\d{4}-\d{1}$/)

            Date.edtf(date_string)
          end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
