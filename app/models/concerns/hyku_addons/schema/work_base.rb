# frozen_string_literal: true

module HykuAddons
  module WorkBase
    extend ActiveSupport::Concern

    include HykuAddons::TaskMaster::WorkBehavior

    # Needs to be defined before schema is included
    class_attribute :json_fields, :date_fields
    self.json_fields = {}
    self.date_fields = []
  end
end
