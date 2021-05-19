namespace :task_master do
  desc "Generate Account Entries"
  task publish_accounts: :environment do
    Account.all.each do |account|
      HykuAddons::TaskMaster::PublishJob.perform_now(:tenant, :create, account.to_task_master)
    end
  end
end
