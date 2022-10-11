# frozen_string_literal: true
module HykuAddons
  module WorkIndexerBehavior
    extend ActiveSupport::Concern

    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc["creator_display_ssim"] = format_names(:creator) if object.respond_to? :creator
        solr_doc["contributor_display_ssim"] = format_names(:contributor) if object.respond_to? :contributor
        solr_doc["editor_display_ssim"] = format_names(:editor) if object.respond_to? :editor
        solr_doc[Solrizer.solr_name("account_cname", :stored_searchable)] = Site.instance&.account&.cname
        # creates key with "date_published_ssi"
        solr_doc[Solrizer.solr_name("date_published", :stored_sortable)] = object.date_published if object.date_published.present?
      end
    end

    private

      FIELD_ORDERS = {
        creator: ["creator_family_name", "creator_given_name", "creator_organization_name"],
        editor: ["editor_family_name", "editor_given_name", "editor_organization_name"],
        contributor: ["contributor_family_name", "contributor_given_name", "contributor_organization_name"]
      }.freeze

      def format_names(field)
        return nil unless object&.send(field)&.first.present?
        JSON.parse(object.send(field).first).collect do |hash|
          hash.slice(*FIELD_ORDERS[field]).values.map(&:presence).compact.map(&:strip).join(", ")
        end
      end
  end
end
