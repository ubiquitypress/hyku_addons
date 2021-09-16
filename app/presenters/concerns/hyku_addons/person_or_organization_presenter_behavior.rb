# frozen_string_literal: true

module HykuAddons
  module PersonOrOrganizationPresenterBehavior
    extend ActiveSupport::Concern

    def creator_list
      @creator_list ||= person_or_organization_list(:creator)
    end

    def contributor_list
      @contributor_list ||= person_or_organization_list(:contributor)
    end

    # TODO: Add view_context and use link_to and image_tag instead of <%== in the view
    # TODO: Need to normalize ids in the work model in  order for these methods to work in all cases (and stay simple)
    class PersonOrOrganization < Struct.new(:display_name, :orcid, :isni, :ror, :grid, :wikidata)
      include Hyrax::Orcid::OrcidHelper

      def orcid_url
        "https://orcid.org/#{validate_orcid(orcid)}" if orcid.present?
      end

      def orcid_logo
        orcid_logo_url = 'https://s3-eu-west-1.amazonaws.com/service-hyku-oar-importer/orcid_16x16.png'
        "<img src='#{orcid_logo_url}' alt='ORCID' height='16' width='16' class='img-responsive' />"
      end

      def orcid_link
        "<a href='#{orcid_url}' target='_blank'>#{orcid_logo}</a>" if orcid.present?
      end

      def isni_url
        "https://isni.org/isni/#{isni.gsub(/[^a-z0-9X]/, '')}" if isni.present?
      end

      def isni_logo
        isni_logo_url = 'https://s3-eu-west-1.amazonaws.com/service-hyku-oar-importer/logo_xml_isni-16.gif'
        "<img src='#{isni_logo_url}' alt='ISNI' height='16' width='16' class='img-responsive' />"
      end

      def isni_link
        "<a href='#{isni_url}' target='_blank'>#{isni_logo}</a>" if isni.present?
      end

      def ror_url
        "https://ror.org/#{ror}" if ror.present?
      end

      def ror_logo
        '<img src=" " alt="ROR" class="img-responseive" sytyle="float:left;">'
      end

      def ror_link
        "<a href='#{ror_url}' target='_blank'>#{ror_logo}</a>" if ror.present?
      end

      def grid_url
        "https://grid.ac/institutes/#{grid}" if grid.present?
      end

      def grid_logo
        '<img src=" " alt="GRID" class="img-responseive" sytyle="float:left;">'
      end

      def grid_link
        "<a href='#{grid_url}' target='_blank'>#{grid_logo}</a>" if grid.present?
      end

      def wikidata_url
        "https://www.wikidata.org/entity/#{wikidata}" if wikidata.present?
      end

      def wikidata_logo
        '<img src=" " alt="WIKIDATA" class="img-responseive" sytyle="float:left;">'
      end

      def wikidata_link
        "<a href='#{wikidata_url}' target='_blank'>#{wikidata_logo}</a>" if wikidata.present?
      end
    end

    private

      def person_or_organization_list(field)
        return if (field_value = solr_document.public_send(field).first.presence || "[]").blank?

        JSON.parse(field_value).collect do |hash|
          name = hash.slice("#{field}_family_name", "#{field}_given_name", "#{field}_organization_name").values.map(&:presence).compact.join(', ')
          PersonOrOrganization.new(name, hash["#{field}_orcid"], hash["#{field}_isni"], hash["#{field}_ror"], hash["#{field}_grid"], hash["#{field}_wikidata"])
        end
      end
      alias participants person_or_organization_list
  end
end
