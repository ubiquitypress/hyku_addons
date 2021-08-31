# frozen_string_literal: true
namespace :task_master do
  desc "Generate Account Entries"
  task publish_accounts: :environment do
    Account.all.each do |account|
      HykuAddons::TaskMaster::PublishJob.perform_later("tenant", "upsert", account.to_task_master.to_json)
    end
  end
end
