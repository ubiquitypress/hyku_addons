# frozen_string_literal: true

module HykuAddons
  module Schema
    module WorkBase
      extend ActiveSupport::Concern

      include HykuAddons::TaskMaster::WorkBehavior

      # Needs to be defined before schema is included
      included do
        class_attribute :json_fields, :date_fields
        self.json_fields = {}
        self.date_fields = []
      end

      def schema_driven?
        true
      end
    end
  end
end
