# frozen_string_literal: true

namespace :hyku do
  namespace :account do
    desc 'Create an account'
    task :create, [:name] => [:environment] do |_t, args|
      CreateAccount.new(Account.new(name: args[:name])).save
    end
  end
end
