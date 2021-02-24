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

    desc 'Update the frontend url of an account'
    task :frontend_url, [:tenant, :frontend_url] => [:environment] do |_t, args|
      account = Account.find_by(tenant: args[:tenant])
      if HykuAddons::UpdateAccountFrontendUrl.new(account, args[:frontend_url]).perform
        Rails.logger.info "Account #{account.tenant} frontend_url successfully changed"
      else
        Rails.logger.error "The operation could not be completed"
      end
    end

    desc 'destroy an account and all the data within'
    task :cleanup, [:name] => [:environment] do |_t, args|
      account = Account.find_by(name: args[:name])
      if account.present? && check_confirmation
        if CleanupAccountJob.perform_now(account)
          puts "Account successfully deleted"
          exit 0
        end
      end
      puts "Could not cleanup the tenant"
      exit 1
    end
  end
end

def check_confirmation
  unless ENV['CONFIRM'] == 'yes'
    $stderr.puts <<-EOC
WARNING: This process will destroy all data for this tenant in:
DB: All tables
Fedora: #{ActiveFedora.fedora.build_connection.http.url_prefix}
Solr: #{ActiveFedora.solr_config[:url]}
Redis: #{Sidekiq.redis { |c| c._client.options.values_at(:host, :port, :db).join(':') }}
Please run `rake app:hyku::account::cleanup[{name}] CONFIRM=yes` to confirm.
    EOC
    exit 1
  end
  true
end
