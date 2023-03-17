# frozen_string_literal: true

namespace :hyku_addons do

  namespace :sso do
    desc "Enable sso for a tenant"
    task :enable, [:cname,:organisation_id,:connection_id] => [:environment] do |_cmd, args|
      Account.find_by(cname: args[:cname])
             .update(enable_sso: true, work_os_orgnaisation: args[:organisation_id], work_os_connection_id: args[:connection_id])

      puts "SSO Enabled for " + args[:cname]
    end

    desc "Disable sso for a tenant"
    task :disable, [:cname] => [:environment] do |_cmd, args|
      Account.find_by(cname: args[:cname])
             .update(enable_sso: false)

      puts "SSO Disabled for " + args[:cname]
    end

  end
end
