# frozen_string_literal: true

module HykuAddons
  class TaskMasterWorkService
    KEY_FILE_CONTENT = ENV["PUBSUB_KEY"] # content of the service account key file
    PROJECT_ID = "up-tools"
    # repository--<type>-<action>: repository--work-submission
    TOPICS = %i[submission update destroy].freeze

    def initialize(work_id)
      @work = ActiveFedora::Base.find(work_id)
    end

    #
    def perform
      byebug
    end

    protected

    def work_metadata
      {
        'tenant': Site.instance.account.tenant,
        'uuid': @work.id,
        'metadata': {
          'title': @work.title.first,
          'etc': {}
        }
      }.to_json
    end

    def file_metadata(fileset)
      {
        'uuid': filset.id,
        'work': @work.id,
        'name': fileset.label,
        'metadata': {
          'title': filset.title.first,
          'etc': {}
        }
      }
    end
  end
end
