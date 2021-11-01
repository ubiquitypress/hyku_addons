# frozen_string_literal: true

# run from  the terminal with and the rake task takes one argument
# Note the tenant name is supplied when running the rake task, for example
# if the tenant name is 'sandbox.repo-test.ubiquity.press', you will pass it as shown below
# for example if the tenant cname is 'sandbox.repo-test.ubiquity.press' run as shown below
# in development
# rake "app:reindex_add_account_cname:run[pacific.hyku.docker]"
# in production
# rake reindex_add_account_cname:run[pacific.hyku.docker,lib.hyku.docker]

namespace :reindex_add_account_cname do
  desc "Add tenant cname to works created before the feature to add tenant cname
       to work was implemented"

  task :run, [:name] => :environment do |_task, args|
    cname_list = Array.wrap(args.to_a)
    ::HykuAddons::ReindexAvailableWorksJob.perform_later(cname_list)
  end
end
