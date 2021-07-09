# frozen_string_literal: true
module HykuAddons
  module Validations
    class ImporterReportService
      def initialize(importer = nil)
        raise ArgumentError, "You need to pass a valid importer" unless importer.present?
        @importer = importer
      end

      def perform(context = nil)
        @statuses = Bulkrax::Status.where(statusable_type: 'Bulkrax::Entry').where(statusable_id: @importer.entry_ids)
        CSV.generate do |csv|
          csv << %i[import_id import_name entry_id identifier status link]
          @statuses.each do |status|
            entry = status.statusable
            csv << [@importer.id, @importer.name, entry.id, entry.identifier, status.status_message,
                    context.bulkrax.importer_entry_url(@importer.id, entry.id), entry.last_error_at || entry.last_succeeded_at]
          end
        end
      end
    end
  end
end
