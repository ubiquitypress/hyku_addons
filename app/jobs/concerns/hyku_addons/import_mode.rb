# frozen_string_literal: true

module HykuAddons
  module ImportMode
    extend ActiveSupport::Concern

    def queue_name
      return super if non_tenant_job?
      switch do
        puts "Job: #{self.class}. Bulk is #{bulk?}"
        Rails.logger.info "Job: #{self.class}. Bulk is #{bulk?}"
        return super unless bulk?
        puts "queue name will now be #{[current_account.name, "import", super].join(ActiveJob::Base.queue_name_delimiter)}"
        Rails.logger.info "queue name will now be #{[current_account.name, "import", super].join(ActiveJob::Base.queue_name_delimiter)}"
        [current_account.name, "import", super].join(ActiveJob::Base.queue_name_delimiter)
      end
    end

    private

      def bulk?
        portable_object&.bulk || false
      rescue NoMethodError
        puts "No flag"
        false
      end

      def portable_object
        nil
      end
  end
end
