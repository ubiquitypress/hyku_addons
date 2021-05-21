# frozen_string_literal: true

require "google/cloud/pubsub"

module HykuAddons
  module TaskMaster
    class PublishService
      ALLOWED_TYPES = %w[tenant file work].freeze
      ALLOWED_ACTIONS = %w[upsert destroy].freeze

      ##
      # @api public
      #
      # Init

      # @param [String] the type instance type
      # @param [String] the CRUD action being performed
      # @param [JSON] the JSON string to be published
      #
      # @return [HykuAddons::TaskMaster::PublishService]
      def initialize(type, action, json)
        @type = type
        @action = action
        @json = json

        validate_arguments!
      end

      ##
      # @api public
      #
      # Publish a message to Google PubSub
      #
      # @return [Google::Cloud::PubSub::Message] or nil
      def perform
        # Without this check, a lot of specs will fail
        return unless Flipflop.enabled?(:task_master)

        topic = client.topic(topic_name)
        topic.publish(@json)
      end

      protected

        def topic_name
          "repository--#{@type}-#{@action}"
        end

        def client
          @client ||= begin
                        Google::Cloud::PubSub.configure do |config|
                          config.project_id  = pubsub_credentials.dig("project_id")
                          config.credentials = pubsub_credentials
                        end

                        Google::Cloud::PubSub.new
                      end
        end

        def pubsub_credentials
          raise KeyError, "Service environment variable is not set" unless ENV["PUBSUB_SERVICEACCOUNT_KEY"].present?

          @pubsub_credentials ||= JSON.parse(ENV["PUBSUB_SERVICEACCOUNT_KEY"])
        end

      private

        def validate_arguments!
          raise ArgumentError, "Type '#{@type}' is invalid" unless ALLOWED_TYPES.include?(@type.to_s)
          raise ArgumentError, "Action '#{@action}' is invalid" unless ALLOWED_ACTIONS.include?(@action.to_s)
          raise ArgumentError, "A JSON string is required" unless @json.is_a?(String)
        end
    end
  end
end
