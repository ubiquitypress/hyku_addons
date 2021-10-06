# frozen_string_literal: true

namespace :hyku do
  namespace :account do
    desc 'Create an account'
    task :create, [:name, :uuid, :cname, :admin_emails] => [:environment] do |_t, args|
      account = Account.new(name: args[:name], tenant: args[:uuid].presence, cname: args[:cname].presence)
      CreateAccount.new(account).save
      AccountElevator.switch!(account.cname)
      Array.wrap(args.to_a[3..-1]).each do |admin_email|
        User.invite!(email: admin_email) do |u|
          u.add_role(:admin)
        end
      end
    end

    # example usage
    # bundle exec rake 'app:hyku:account:create_shared[sample, 1ab4, sample.hyku.docker, 27,29 ]'
    desc 'Create a shared search account'
    task :create_shared, [:name, :uuid, :cname, :tenant_ids] => [:environment] do |_t, args|
      tenant_list = Array.wrap(args.to_a[3..-1])

      raise ArgumentError, 'Provide a list of tenants seperated by commas as last argument' if tenant_list.empty?

      puts "====== instantiating a shared-search account"

      account = Account.new(name: args[:name], tenant: args[:uuid].presence, cname: args[:cname].presence,
                            search_only: true, full_account_ids: tenant_list)

      CreateAccount.new(account).save

      puts "====== shared-search account created"
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
\tBase Path: #{account.fcrepo_endpoint.options&.fetch(:base_path) unless account.search_only?}
Solr:
\tConnection: #{ActiveFedora.solr_config[:url]}
\tCollection: #{account.solr_endpoint.options&.fetch(:collection)}
Redis:
\tConnection: #{Sidekiq.redis { |c| c._client.options.values_at(:host, :port, :db).join(':') }}
\tNamespace: #{account.redis_endpoint.options&.fetch(:namespace)}

Please run `rake hyku:account:cleanup[{tenant}] CONFIRM=yes` to confirm.
    EOC
    exit 1
  end
  true
end
