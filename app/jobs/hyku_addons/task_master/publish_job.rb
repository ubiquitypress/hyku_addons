# frozen_string_literal: true

module HykuAddons
  module TaskMaster
    class PublishJob < ApplicationJob
      discard_on ArgumentError

      def perform(type, action, json)
        HykuAddons::TaskMaster::PublishService.new(type, action, json).perform
      end
    end
  end
end
