# frozen_string_literal: true

namespace :hyku do
  namespace :validations do
    namespace :importers do
      desc 'Validate a Bulkrax Importer'
      task :http, [:tenant, :importer, :source_path, :source_auth, :destination_path, :destination_auth] => [:environment] do |_t, args|
        account = load_account(args[:tenant])
        importer = Bulkrax::Importer.find(args[:importer])
        validate_http_params(args)

        importer.entries.find_each.map do |entry|
          next unless entry.is_a?(HykuAddons::CsvEntry)
          HykuAddons::ValidateImporterEntryJob.perform_later(account, entry, source_auth_options(args), destination_auth_options(args))
        end
      end

      task :cookies, [:tenant, :importer, :source_path, :source_cookie, :destination_path, :destination_cookie] => [:environment] do |_t, args|
        account = load_account(args[:tenant])
        importer = Bulkrax::Importer.find(args[:importer])
        validate_cookie_params(args)
        importer.entries.find_each.map do |entry|
          next unless entry.is_a?(HykuAddons::CsvEntry)
          HykuAddons::ValidateImporterEntryJob.perform_later(account, entry, source_cookie_options(args), destination_cookie_options(args))
        end
      end

      task :csv, [:tenant, :importer] => [:environment] do |_t, args|
        account = load_account(args[:tenant])
        importer = Bulkrax::Importer.find(args[:importer])

        importer.entries.find_each.map do |entry|
          next unless entry.is_a?(HykuAddons::CsvEntry)
          HykuAddons::ValidateCsvImporterEntryJob.perform_later(account, entry)
        end
      end
    end

    namespace :entries do
      desc 'Validate a Bulkrax Entry'
      task :http, [:tenant, :entry, :source_path, :source_auth, :destination_path, :destination_auth] => [:environment] do |_t, args|
        account = load_account(args[:tenant])
        entry = Bulkrax::Entry.find(args[:entry])
        exit(1) unless entry.is_a?(HykuAddons::CsvEntry)

        HykuAddons::ValidateImporterEntryJob.perform_later(account, entry, source_auth_options(args), destination_auth_options(args))
      end

      task :cookies, [:tenant, :entry, :source_path, :source_cookie, :destination_path, :destination_cookie] => [:environment] do |_t, args|
        account = load_account(args[:tenant])
        entry = Bulkrax::Entry.find(args[:entry])
        validate_cookie_params(args)
        exit(1) unless entry.is_a?(HykuAddons::CsvEntry)

        HykuAddons::ValidateImporterEntryJob.perform_later(account, entry, source_cookie_options(args), destination_cookie_options(args))
      end

      task :csv, [:tenant, :entry] => [:environment] do |_t, args|
        account = load_account(args[:tenant])
        entry = Bulkrax::Entry.find(args[:entry])
        exit(1) unless entry.is_a?(HykuAddons::CsvEntry)

        HykuAddons::ValidateCsvImporterEntryJob.perform_later(account, entry)
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

def validate_http_params(args)
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
end

def validate_cookie_params(args)
  %w[source destination].each do |location|
    unless args["#{location}_path"].present?
      puts "You need to pass a metadata path at #{location}_path"
      exit(1)
    end

    unless args["#{location}_cookie"].present?
      puts "You need to pass a cookie as cookie_name=xxx at #{location}_auth"
      exit(1)
    end
  end
end

def source_auth_options(args)
  {
    base_url: args[:source_path],
    username: args[:source_auth].split(':')[0],
    password: args[:source_auth].split(':')[1]
  }
end

def destination_auth_options(args)
  {
    base_url: args[:destination_path],
    username: args[:destination_auth].split(':')[0],
    password: args[:destination_auth].split(':')[1]
  }
end

def source_cookie_options(args)
  {
    base_url: args[:source_path],
    cookie: args[:source_cookie]
  }
end

def destination_cookie_options(args)
  {
    base_url: args[:destination_path],
    cookie: args[:destination_cookie]
  }
end
