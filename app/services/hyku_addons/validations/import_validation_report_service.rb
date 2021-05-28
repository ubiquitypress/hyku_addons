# frozen_string_literal: true
module HykuAddons
  module Validations
    class ImporterValidationReportService
      def initialize(importer = nil, field = nil)
        raise ArgumentError, "You need to pass a valid importer" unless importer.present?
        @importer = importer
        @field = field
        @statuses = Bulkrax::Status.where(statusable_type: 'Bulkrax::Entry').where(statusable_id: @importer.entry_ids)
      end

      def perform
        statuses_with_issues = HykuAddons::StatusValidationIssuesQuery.new(@statuses).call(@field)
        CSV.generate do |csv|
          csv << %i[import_id import_name entry_id work_id attribute operation source_value destination_value
                    transformed_source_value transformed_dest_value]
          statuses_with_issues.each do |status|
            entry = status.statusable
            status.error_backtrace.each do |issue|
              csv << [@importer.id, @importer.name, entry.id, entry.identifier, issue[:path], issue[:op],
                      issue[:source_v], issue[:dest_v], issue[:t_source_v], issue[:t_dest_v]]
            end
          end
        end
      end
    end
  end
end
