# frozen_string_literal: true

module HykuAddons
  module PersonOrOrganizationFormBehavior
    extend ActiveSupport::Concern

    # Helper methods for JSON fields
    def creator_list
      person_or_organization_list(:creator)
    end

    def contributor_list
      person_or_organization_list(:contributor)
    end

    # rubocop:disable Metrics/BlockLength
    class_methods do
      # Group all params here so save on boiler plate
      def build_permitted_params
        super.tap do |permitted_params|
          permitted_params << creator_fields
          permitted_params << contributor_fields
        end
      end

      def creator_fields
        {
          creator: [
            :creator_organization_name, :creator_given_name, :creator_middle_name, :creator_family_name,
            :creator_name_type, :creator_orcid, :creator_isni, :creator_ror, :creator_grid, :creator_wikidata,
            :creator_suffix, :creator_institution, :creator_institutional_email, :creator_computing_id,
            creator_institution: [], creator_role: [], creator_institutional_relationship: []
          ]
        }
      end

      def contributor_fields
        {
          contributor: [
            :contributor_organization_name, :contributor_given_name, :contributor_middle_name,
            :contributor_family_name, :contributor_name_type, :contributor_orcid, :contributor_isni, :contributor_ror,
            :contributor_grid, :contributor_wikidata, :contributor_suffix, :contributor_type, :contributor_institution,
            contributor_institution: [], contributor_role: [], contributor_institutional_relationship: []
          ]
        }
      end
    end

    private

      def person_or_organization_list(field)
        # Return empty hash to ensure that it gets rendered at least once
        return [{}] unless send(field)&.first.present?
        JSON.parse(send(field).first)
      end
  end
end
