# frozen_string_literal: true
namespace :hyku do
  namespace :cache do
    desc 'Expire the tenants cache'
    task :expire, [] => [:environment] do |_t, _args|
      HykuAddons::CacheExpirationService.new.perform
    end
  end
end
