# frozen_string_literal: true

# NOTE:
# Add new fields here that should be available to prefill the work forms.
# You must also add the logic to the PrefillWorkFormViaDOI JS class.
#
# The processed JSON can be access via a JSON request:
# # http://YOUR_TENANT.lvh.me:3000/doi/autofill.xml?curation_concern=generic_work&doi=YOUR_DOI
#
# To create fixtures for specs, the the unprocessed XML can be accessed via an XML request.
# NOTE: Copy the raw source, not the HTML output:
# http://YOUR_TENANT.lvh.me:3000/doi/autofill.xml?curation_concern=generic_work&doi=YOUR_DOI
module Bolognese
  module Writers
    module HykuAddonsWorkFormFieldsWriter
      include HykuAddons::WorkFormNameable
      include Bolognese::Helpers::Dates
      include Bolognese::Helpers::Writers

      UNAVAILABLE_LABEL = ":(unav)"
      DATE_FORMAT = "%Y-%-m-%-d"
      DOI_REGEX = /10.\d{4,9}\/[-._;()\/:A-Z0-9]+/
      ROR_QUERY_URL = "https://api.ror.org/organizations?query="
      AFTER_ACTIONS = %i[process_editor_contributors! ensure_creator_from_editor!].freeze

      def hyku_addons_work_form_fields(curation_concern: "generic_work")
        @curation_concern = curation_concern

        @form_data = process_work_type_terms

        AFTER_ACTIONS.map { |action| send(action) }

        # Work through each of the work types fields to create the data hash
        @form_data.compact.reject { |_key, value| value.blank? }
      end

      private

        def process_work_type_terms
          work_type_terms.each_with_object({}) do |term, data|
            method_name = "write_#{term}"

            data[term.to_s] = respond_to?(method_name, true) ? send(method_name) : nil
          end
        end

        # Required for WorkFormNameable to function correctly
        def meta_model
          @curation_concern.classify
        end

        # If we have no creator, but we do have editors, then we need to transform the editor contributors to creators
        def ensure_creator_from_editor!
          return unless @form_data["creator"].first&.dig("creator_name") == UNAVAILABLE_LABEL
          return unless @form_data["editor"].present?

          @form_data["creator"] = @form_data.delete("editor").map! do |cont|
            cont.transform_keys! { |key| key.gsub("contributor", "creator") }
          end
        end

        def process_editor_contributors!
          editors = proc { |item| item["contributor_contributor_type"] == "Editor" }

          # If we do not have editors, they might be missing from the fields for this work type.
          # This is so that we can reliably use them later on in the callbacks chain
          @form_data["editor"] = @form_data["contributor"].select(&editors) if @form_data["editor"].blank? && @form_data["contributor"].any?(&editors)

          # If we have editors, then they are formed from contributor data, which can be removed to avoid duplication
          @form_data["contributor"].reject!(&editors)
        end
    end
  end
end
