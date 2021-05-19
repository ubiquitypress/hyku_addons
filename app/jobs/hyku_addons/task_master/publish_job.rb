# frozen_string_literal: true

module HykuAddons
  module TaskMaster
    class PublishJob < ApplicationJob
      discard_on ArgumentError

      def perform(type, action, data)
        HykuAddons::TaskMaster::PublishService.new(type, action, data).perform
      end
    end
  end
end

