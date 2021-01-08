# frozen_string_literal: true
module HykuAddons
  module WorkForm
    extend ActiveSupport::Concern

    # Helper methods for JSON fields
    def creator_list
      person_or_organization_list(:creator)
    end

    def contributor_list
      person_or_organization_list(:contributor)
    end

    class_methods do
      def common_fields
        [:title, :resource_type, :alternative_name, :project_name, :institution, :abstract, :official_link, :related_url,
         :language, :license, :rights_statement, :rights_holder, :doi, :peer_reviewed, :keywords, :dewey, :library_of_congress_classification,
         :add_info, creator_fields, contributor_fields, date_published_fields, date_accepted_fields, date_submitted_fields,
         funder_fields, related_identifier_fields, alternate_identifier_fields]
      end

      def creator_fields
        { creator: [:creator_organization_name, :creator_given_name, :creator_family_name, :creator_name_type, :creator_orcid,
                    :creator_isni, :creator_ror, :creator_grid, :creator_wikidata, creator_institutional_relationship: []] }
      end

      def contributor_fields
        { contributor: [:contributor_organization_name, :contributor_given_name, :contributor_family_name, :contributor_name_type,
                        :contributor_orcid, :contributor_isni, :contributor_ror, :contributor_grid, :contributor_wikidata,
                        :contributor_type, contributor_institutional_relationship: []] }
      end

      def date_accepted_fields
        { date_accepted: [:date_accepted_year, :date_accepted_month, :date_accepted_day] }
      end

      def date_published_fields
        { date_published: [:date_published_year, :date_published_month, :date_published_day] }
      end

      def date_submitted_fields
        { date_submitted: [:date_submitted_year, :date_submitted_month, :date_submitted_day] }
      end

      def editor_fields
        { editor: [:editor_isni, :editor_orcid, :editor_family_name, :editor_given_name, :editor_organisational_name,
                   :editor_institutional_relationship] }
      end

      def funder_fields
        { funder: [:funder_name, :funder_doi, :funder_isni, :funder_ror, funder_award: []] }
      end

      def alternate_identifier_fields
        { alternate_identifier: [:alternate_identifier, :alternate_identifier_type] }
      end

      def related_identifier_fields
        { related_identifier: [:related_identifier, :related_identifier_type, :relation_type] }
      end

      def event_date_fields
        { event_date: [:event_date_year, :event_date_month, :event_date_day] }
      end

      def current_he_institution_fields
        { current_he_institution: [:current_he_institution_name, :current_he_institution_isni, :current_he_institution_ror] }
      end

      def related_exhibition_date_fields
        { related_exhibition_date: [:related_exhibition_date_year, :related_exhibition_date_month, :related_exhibition_date_day] }
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
