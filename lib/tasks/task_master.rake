# frozen_string_literal: true
namespace :task_master do
  desc "Generate Account Entries"
  task publish_accounts: :environment do
    Account.all.each do |account|
      publish_to_task_master("tenant", account.to_task_master)
    end
  end

  desc "Publish all types to Google PubSub"
  task publish_all: :environment do
    Account.all.each do |account|
      publish_to_task_master("tenant", account.to_task_master)

      AccountElevator.switch!(account.cname)

      request = ActiveFedora::SolrService.get('generic_type_sim:Work', fl: [:id], rows: 1_000_000)
      request['response']['docs'].pluck('id').each do |id|
        work = ActiveFedora::Base.find(id)

        publish_to_task_master("work", work.to_task_master)

        next unless work.file_sets.present?

        work.file_sets.each do |file|
          publish_to_task_master("file", file.to_task_master)
        end
      end
    end
  end
end

def publish_to_task_master(type, data)
  HykuAddons::TaskMaster::PublishJob.perform_later(type, "upsert", data.to_json)
end
