# frozen_string_literal: true
# Customer organization account
module HykuAddons
  module AccountBehavior
    extend ActiveSupport::Concern

    included do
      belongs_to :datacite_endpoint, dependent: :delete
      has_many :children, class_name: "Account", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
      belongs_to :parent, class_name: "Account", inverse_of: :parent, foreign_key: "parent_id", optional: true

      store_accessor :data, :is_parent
      store_accessor :settings, *AccountSettingsCollection.all

      accepts_nested_attributes_for :datacite_endpoint, update_only: true
      after_initialize :initialize_settings
    end

    def datacite_endpoint
      super || NilDataCiteEndpoint.new
    end

    private

      def initialize_settings
        settings.reverse_merge!({
          allow_signup: "true",
          help_texts: {
            subject: nil,
            org_unit: nil,
            refereed: nil,
            additional_information: nil,
            publisher: nil,
            volume: nil,
            pagination: nil,
            isbn: nil,
            issn: nil,
            duration: nil,
            version: nil,
            keyword: nil
          },
          work_unwanted_fields: {
            book_chapter: nil,
            article: nil,
            news_clipping: nil
          },
          required_json_property: {
            media: [],
            presentation: [],
            text_work: [],
            uncategorized: [],
            news_clipping: [],
            article_work: [],
            book_work: [],
            image_work: [],
            thesis_or_dissertation_work: []
          },
          metadata_labels: {
            institutional_relationship: nil,
            family_name: nil,
            given_name: nil,
            org_unit: nil,
            version_number: nil
          }
        }.stringify_keys)
      end
  end
end
