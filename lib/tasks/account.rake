# frozen_string_literal: true

namespace :hyku do
  namespace :account do
    desc 'Create an account'
    task :create, [:name] => [:environment] do |_t, args|
      CreateAccount.new(Account.new(name: args[:name])).save
    end
    desc 'Update the frontend url of an account'
    task :frontend_url, [:tenant, :frontend_url] => [:environment] do |_t, args|
      account = Account.find_by(tenant: args[:tenant])
      UpdateAccountFrontendUrl.new(account, args[:frontend_url]).save
    end
  end
end
