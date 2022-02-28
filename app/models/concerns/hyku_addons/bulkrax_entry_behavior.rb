# frozen_string_literal: true
module HykuAddons
  module BulkraxEntryBehavior
    extend ActiveSupport::Concern

    included do
      has_one :latest_status,
              -> { order(created_at: :desc) },
              class_name: "Bulkrax::Status",
              as: :statusable
      # scope :with_issues_on_field, lambda{ |field| where("error_backtrace LIKE ?", "%#{field}%") }
    end
  end
end
