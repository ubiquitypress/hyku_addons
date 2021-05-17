# frozen_string_literal: true

module HykuAddons
  class TaskMasterWorkService
    KEY_FILE_CONTENT = ENV["PUBSUB_KEY"] # content of the service account key file
    PROJECT_ID = "up-tools"
    # repository--<type>-<action>: repository--work-submission
    TOPICS = %i[create update destroy].freeze

    def initialize(work_id, options = {})
      @work = ActiveFedora::Base.find(work_id)
    end

    def perform
    end

    protected

    def work_metadata
      {
        tenant: tenant,
        uuid: @work.id,
        metadata: { title: @work.title.first }.merge(@work.attributes.except("title"))
      }.to_json
    end

    def file_metadata(fileset)
      {
        uuid: filset.id,
        work: @work.id,
        name: fileset.label,
        metadata: { title: filset.title.first }.merge(file_set.attributes.except("title"))
      }
    end

    def tenant
      @tenant ||= Site.instance.account.tenant
    end
  end
end
