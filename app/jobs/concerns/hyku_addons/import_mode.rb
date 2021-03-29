# frozen_string_literal: true
module HykuAddons
  module ImportMode
    extend ActiveSupport::Concern

    def queue_name
      if non_tenant_job?
        super
      else
        switch do
          if Flipflop.enabled?(:import_mode)
            [current_account.name, 'import', super].join(ActiveJob::Base.queue_name_delimiter)
          else
            super
          end
        end
      end
    end
  end
end
