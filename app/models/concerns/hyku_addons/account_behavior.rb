# frozen_string_literal: true
# Customer organization account
module HykuAddons
  module AccountBehavior
    extend ActiveSupport::Concern

    included do
      belongs_to :datacite_endpoint, dependent: :delete
      accepts_nested_attributes_for :datacite_endpoint, update_only: true
    end

    def datacite_endpoint
      super || NilDataCiteEndpoint.new
    end
  end
end
