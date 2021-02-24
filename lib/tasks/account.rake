# frozen_string_literal: true

namespace :hyku do
  namespace :account do
    desc 'Create an account'
    task :create, [:name, :admin_emails] => [:environment] do |_t, args|
      account = Account.new(name: args[:name])
      CreateAccount.new(account).save
      AccountElevator.switch!(account.cname)
      Array.wrap(args[:admin_emails]).each do |admin_email|
        User.invite!(email: admin_email) do |u|
          u.add_role(:admin)
        end
      end
    end

    desc 'destroy an account and all the data within'
    task :cleanup, [:tenant] => [:environment] do |_t, args|
      account = load_account(args[:tenant])
      if check_confirmation(account)
        if CleanupAccountJob.perform_now(account)
          puts "Account successfully deleted"
          exit 0
        end
      end
      puts "Could not cleanup the tenant"
      exit 1
    end

    desc 'Update the frontend url of an account'
    task :frontend_url, [:tenant, :frontend_url] => [:environment] do |_t, args|
      account = load_account(args[:tenant])
      if HykuAddons::UpdateAccountFrontendUrl.new(account, args[:frontend_url]).perform
        Rails.logger.info "Account #{account.tenant} frontend_url successfully changed"
      else
        Rails.logger.error "The operation could not be completed"
      end
    end

    desc 'Update the cname of an account'
    task :cname, [:tenant, :cname] => [:environment] do |_t, args|
      account = load_account(args[:tenant])
      if HykuAddons::UpdateAccountCname.new(account, args[:cname]).perform
        Rails.logger.info "Account #{account.tenant} cname successfully changed"
      else
        Rails.logger.error "The operation could not be completed"
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
  account
end

def check_confirmation(account)
  unless ENV['CONFIRM'] == 'yes'
    $stderr.puts <<-EOC
WARNING: This process will destroy all data for this tenant in:
DB: All tables
Fedora:
\tConnection: #{ActiveFedora.fedora.build_connection.http.url_prefix}
\tBase Path: #{account.fcrepo_endpoint.options[:base_path]}
Solr:
\tConnection: #{ActiveFedora.solr_config[:url]}
\tCollection: #{account.solr_endpoint.options[:collection]}
Redis:
\tConnection: #{Sidekiq.redis { |c| c._client.options.values_at(:host, :port, :db).join(':') }}
\tNamespace: #{account.redis_endpoint.options[:namespace]}

Please run `rake hyku:account:cleanup[{tenant}] CONFIRM=yes` to confirm.
    EOC
    exit 1
  end
  true
end
