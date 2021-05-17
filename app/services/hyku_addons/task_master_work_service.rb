# frozen_string_literal: true

require "google/cloud/pubsub"

module HykuAddons
  class TaskMasterWorkService
    KEY_FILE_CONTENT = ENV["PUBSUB_KEY"] # content of the service account key file
    PROJECT_ID = "up-tools"
    TOPICS = %w[create update destroy].freeze

    def initialize(work_id, options = {})
      @work = ActiveFedora::Base.find(work_id)
      @options = options
    end

    def perform
      client.topic topic_for(:work)
      client.publish work_metadata

      return unless @work.file_sets.present?

      @work.file_sets.each do |file_set|
        client.topic topic_for(:file)
        client.publish fileset_metadata(file_set)
      end
    end

    protected

    # repository--<type>-<action>: repository--work-create
    def topic_for(type)
      return "repository--#{@options[:action]}-#{type}" if TOPICS.include?(@options[:action])

      raise ArgumentError, "The action '#{@options[:action]}' could not be processed"
    end

    def work_metadata
      {
        tenant: tenant,
        uuid: @work.id,
        metadata: { title: @work.title.first }.merge(@work.attributes.except("title"))
      }.to_json
    end

    def fileset_metadata(fileset)
      {
        uuid: filset.id,
        work: @work.id,
        name: fileset.label,
        metadata: { title: filset.title.first }.merge(file_set.attributes.except("title"))
      }.to_json
    end

    def tenant
      @tenant ||= Site.instance.account.tenant
    end

    def client
      @client ||= Google::Cloud::PubSub.new
    end
  end
end
