# frozen_string_literal: true

namespace :task_master do
  desc "Generate Account Entries"
  task publish_accounts: :environment do
    Account.all.each do |account|
      publish_to_task_master("tenant", account.to_task_master)
    end
  end

  task count_all: :environment do
    Account.all.each do |account|
      AccountElevator.switch!(account.cname)

      works = ActiveFedora::SolrService.get("generic_type_sim:Work", fl: [:id], rows: 1_000_000).dig("response", "numFound")
      puts "#{account.cname}: #{works}"
    rescue RSolr::Error::ConnectionRefused
      puts "#{account.cname}: Solr Error"
    end
  end


  # NOTE: The reason there is such a large delay (1 second to 3 dys) on the task is to avoid flooding Fedora,
  # which is incredibly slow and can get backlogged very quickly, causing jobs to fail and be rescheduled,
  # running again and causing a cascade of failures which ends up using up all resources.
  desc "Publish all types to Google PubSub"
  task publish_all: :environment do
    Account.all.each do |account|
      # Accounts can be reimported immediately as there are very few of them
      publish_to_task_master("tenant", account.to_task_master)

      AccountElevator.switch!(account.cname)

      works = ActiveFedora::SolrService.get("generic_type_sim:Work", fl: [:id], rows: 1_000_000)
        .dig("response", "numFound")
        .map { |doc| ActiveFedora::SolrHit.new(doc).reify }

      works.each do |work|
        # Calculate a random time in the next 48 hours for the work to be imported
        delay = rand(1..2.days.seconds)

        publish_to_task_master("work", work.to_task_master, delay)

        next unless work.file_sets.present?

        # Schedule any files to be imported 1 day after the work is imported to avoid flooding
        work.file_sets.each { |file| publish_to_task_master("file", file.to_task_master, delay + 1.day.seconds) }
      end

    rescue RSolr::Error::ConnectionRefused
      nil
    end
  end
end

def publish_to_task_master(type, data, wait = 0)
  HykuAddons::TaskMaster::PublishJob.set(wait: wait).perform_later(type, "upsert", data.to_json)
end
