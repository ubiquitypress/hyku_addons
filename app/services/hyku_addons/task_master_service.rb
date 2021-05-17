# frozen_string_literal: true

# https://ubiquitypress.atlassian.net/browse/REPO-112
#
## Python Libraries:
#
# google-api-python-client==1.12.5
# google-auth==1.23.0
# google-cloud-pubsub==1.7.0
#
# import json
# from google.cloud import pubsub_v1
# from google.auth import jwt  # pubsub seems to use this instead
#
# key_file_content = 'key_file_content'  # content of the service account key file
# project_id = "up-tools"
# topic_id = "repository-work-submissions"  # Will need to create a new topic for this
# publisher_audience = "https://pubsub.googleapis.com/google.pubsub.v1.Publisher"
# credentials_pub = jwt.Credentials.from_service_account_info(
#     key_file_content,
#     audience=publisher_audience
# )
# client = pubsub_v1.PublisherClient(credentials=credentials_pub)
# topic_path = client.topic_path(project_id, topic_id)
# data = {'demo': 'data'}
# data_json = json.dumps(data).encode('utf-8')  # Needs to be sent as bytes
# api_future = client.publish(topic_path, data_json)
# message_id = api_future.result()
#
# print(f"Published {data} to {topic_path}: {message_id}")

module HykuAddons
  class TaskMasterService
    KEY_FILE_CONTENT = ENV["PUBSUB_KEY"] # content of the service account key file
    PROJECT_ID = "up-tools"
    # repository--<type>-<action>: repository--work-submission
    TOPICS = %i[submission update destroy].freeze

    def initialize(work_id)
      @work = ActiveFedora::Base.find(work_id)
    end

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
