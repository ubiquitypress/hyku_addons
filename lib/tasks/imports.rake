# frozen_string_literal: true

namespace :hyku do
  namespace :importers do
    desc 'Validate an import entry'
    task :validate, [:tenant, :importer, :source_path, :source_auth, :destination_path, :destination_auth] => [:environment] do |_t, args|
      account = load_account(args[:tenant])
      importer = Bulkrax::Importer.find(args[:importer])

      %w[source destination].each do |location|
        unless args["#{location}_path"].present?
          puts "You need to pass a metadata path at #{location}_path"
          exit(1)
        end

        unless args["#{location}_auth"]&.split(':')&.count == 2
          puts "You need to pass a credentials as username:password at #{location}_auth"
          exit(1)
        end
      end

      source_auth_options = {
        base_url: args[:source_path],
        username: args[:source_auth].split(':')[0],
        password: args[:source_auth].split(':')[1]
      }
      destination_auth_options = {
        base_url: args[:destination_path],
        username: args[:destination_auth].split(':')[0],
        password: args[:destination_auth].split(':')[1]
      }

      importer.entries.find_each.map do |entry|
        next unless entry.is_a?(HykuAddons::CsvEntry)
        HykuAddons::ValidateImporterEntryJob.perform_later(account, entry, source_auth_options, destination_auth_options)
      end
    end
  end
end

def load_account(tenant)
  account = Account.find_by(tenant: tenant)
  if account.blank?
    puts "Account not found"
    exit(1)
  end
  AccountElevator.switch!(account.cname)
  account
end
