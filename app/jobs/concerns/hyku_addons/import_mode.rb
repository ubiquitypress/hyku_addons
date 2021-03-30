# frozen_string_literal: true
module HykuAddons
  module ImportMode
    extend ActiveSupport::Concern

    def queue_name
      return super if non_tenant_job?
      switch do
        return super unless Flipflop.enabled?(:import_mode)
        [current_account.name, 'import', super].join(ActiveJob::Base.queue_name_delimiter)
      end
    end
  end
end
