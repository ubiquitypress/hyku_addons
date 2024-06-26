# frozen_string_literal: true
module HykuAddons
  module Schema
    module WorkForm
      extend ActiveSupport::Concern

      include HykuAddons::NoteFormBehavior

      # rubocop:disable Metrics/BlockLength
      class_methods do
        # Group all params here so save on boiler plate
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/AbcSize
        def build_permitted_params
          super.tap do |permitted_params|
            permitted_params << common_fields
            permitted_params << file_set_fields
            permitted_params << date_published_fields
            permitted_params << date_accepted_fields
            permitted_params << date_submitted_fields
            permitted_params << editor_fields
            permitted_params << funder_fields
            permitted_params << alternate_identifier_fields
            permitted_params << related_identifier_fields
            permitted_params << alternate_identifier_fields
            permitted_params << event_fields
            permitted_params << current_he_institution_fields
            permitted_params << related_exhibition_fields
            permitted_params << note
          end
        end
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/AbcSize

        # Adds the terms received as params to the work type terms list ensuring the correct order
        # @param work_type_terms [Array] array of terms to add to the work type
        def add_terms(work_type_terms = [])
          self.terms ||= hyrax_terms
          self.terms = (Array.wrap(work_type_terms) + self.terms) & available_terms
        end

        # Form fields. Note, these to not necessarily match the params which need to be permitted
        def available_terms
          %i[title alt_title resource_type creator contributor abstract date_published media duration
            institution org_unit project_name funder fndr_project_ref event_title event_location event_date
            series_name book_title editor journal_title alternative_journal_title volume edition version_number issue
            pagination article_num publisher place_of_publication isbn issn eissn current_he_institution date_accepted
            date_submitted official_link related_url related_exhibition related_exhibition_venue related_exhibition_date
            language license rights_statement rights_holder doi qualification_name qualification_level draft_doi
            alternate_identifier related_identifier refereed keyword dewey library_of_congress_classification add_info
            page_display_order_number irb_number irb_status subject additional_links is_included_in buy_book challenged
            location outcome participant reading_level photo_caption photo_description degree longitude latitude alt_email
            alt_book_title table_of_contents prerequisites suggested_student_reviewers suggested_reviewers adapted_from
            audience related_material note advisor subject_text mesh journal_frequency funding_description
            citation references extent medium source committee_member time qualification_grantor date_published_text
            rights_statement_text qualification_subject_text is_format_of part_of
            georeferenced source_identifier mentor repository_space] + hyrax_terms
        end

        def hyrax_terms
          %i[visibility files visibility_during_embargo embargo_release_date visibility_after_embargo
            visibility_during_lease lease_expiration_date visibility_after_lease admin_set_id member_of_collection_ids
            ordered_member_ids in_works_ids rendering_ids representative_id thumbnail_id]
        end

        def common_fields
          %i[title alt_title resource_type abstract alternative_name project_name institution media official_link
            related_url language license rights_statement rights_holder doi refereed keywords dewey
            library_of_congress_classification add_info issn isbn eissn version_number series_name book_title pagination
            publisher place_of_publication journal_title alternative_journal_title volume edition issue article_num
            qualification_name qualification_level representative_id thumbnail_id]
        end

        def file_set_fields
          { file_set: [:visibility, :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
                      :visibility_during_lease, :lease_expiration_date, :visibility_after_lease, :uploaded_file_id] }
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
          {
            editor: [:editor_isni, :editor_orcid, :editor_family_name, :editor_given_name, :editor_organisational_name,
                    :editor_institutional_relationship]
          }
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

        def event_fields
          [:event_title, :event_location, event_date: [:event_date_year, :event_date_month, :event_date_day]]
        end

        def current_he_institution_fields
          {
            current_he_institution: [:current_he_institution_name, :current_he_institution_isni,
                                    :current_he_institution_ror]
          }
        end

        def related_exhibition_fields
          [
            :related_exhibition,
            :related_exhibition_venue,
            related_exhibition_date: [:related_exhibition_date_year, :related_exhibition_date_month,
                                      :related_exhibition_date_day]
          ]
        end

        def note
          [:note]
        end
      end
      # rubocop:enable Metrics/BlockLength

      included do
        class_attribute :primary_fields, :field_configs, :internal_terms
        self.primary_fields = []
        self.required_fields = []
        self.field_configs = {}
        self.internal_terms = [] # Internal hyrax terms which don't require form fields

        # disable rubocop because we can refactor this method at a later time
        # rubocop:disable Metrics/MethodLength
        def self.build_permitted_params
          super.tap do |permitted_params|
            model_class.json_fields.deep_symbolize_keys.each do |field, field_config|
              subfields = field_config[:subfields].keys.map do |subfield|
                field_config.dig(:subfields, subfield, :form, :multiple) ? { subfield => [] } : subfield
              end

              permitted_params << { field => subfields }
            end

            model_class.date_fields.each do |field|
              permitted_params << { field => ["#{field}_year".to_sym, "#{field}_month".to_sym, "#{field}_day".to_sym] }
            end

            # to address saving of any old field that was single but changed to multiple
            ["rights_statement"].each do |field|
              next unless field_configs.dig(field.to_sym, :multiple)
              permitted_params << { field => [] }
            end
          end
        end
        # rubocop:enable Metrics/MethodLength
      end

      def initialize(model, current_ability, controller)
        model.admin_set_id = controller.params["admin_set_id"] if simplified_admin_set?(controller)

        super(model, current_ability, controller)
      end

      def schema_driven?
        true
      end

      def primary_terms
        pt = primary_fields | super
        pt += %i[admin_set_id] if Flipflop.enabled?(:simplified_admin_set_selection)
        pt += %i[doi]

        pt.uniq
      end

      # Helper methods for JSON fields
      def creator_list
        person_or_organization_list(:creator)
      end

      def contributor_list
        person_or_organization_list(:contributor)
      end

      def editor_list
        person_or_organization_list(:editor)
      end

      # A generic method to avoid needing a custom method for all JSON fields
      def json_field_list(field)
        person_or_organization_list(field.to_sym)
      end

      private

      def simplified_admin_set?(controller)
        Flipflop.enabled?(:simplified_admin_set_selection) && controller&.params&.dig("admin_set_id").present?
      end

      def person_or_organization_list(field)
        # Return empty hash to ensure that it gets rendered at least once
        return [{}] unless respond_to?(field) && send(field)&.first.present?

        JSON.parse(send(field).first)
      end
    end
  end
end
