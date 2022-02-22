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

      def total_collection_entries
        portable_object
          &.importerexporter
          &.importer_runs
          &.first
          &.total_collection_entries || 0
      rescue NameError
        0
      end

      def bulk?
        total_collection_entries > 20 || false
      end
  end
end
