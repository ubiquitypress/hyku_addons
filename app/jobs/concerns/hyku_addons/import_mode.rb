# frozen_string_literal: true
# rubocop:disable Rails/Output

module HykuAddons
  module ImportMode
    extend ActiveSupport::Concern

    def queue_name
      return super if non_tenant_job?
      switch do
        puts "Job: #{self.class}. Bulk is #{bulk?}"
        Rails.logger.info "Job: #{self.class}. Bulk is #{bulk?}"
        return super unless bulk?
        puts "queue name will now be #{[current_account.name, 'import', super].join(ActiveJob::Base.queue_name_delimiter)}"
        Rails.logger.info "queue name will now be #{[current_account.name, 'import', super].join(ActiveJob::Base.queue_name_delimiter)}"
        [current_account.name, "import", super].join(ActiveJob::Base.queue_name_delimiter)
      end
    end

    private

      def total_entries
        portable_object
          &.parser
          &.total || 0
      rescue NameError
        0
      end

      def bulk?
        (total_entries > bulkrax_bulk_job_threshold) || false
      end

      def bulkrax_bulk_job_threshold
        ENV["BULKRAX_BULK_JOB_THRESHOLD"] || 10
      end
  end
end
