# frozen_string_literal: true

module HykuAddons
  class ValidateCsvImporterJob < ApplicationJob
    # non_tenant_job
    def perform(account, importer, klass)
      AccountElevator.switch! account.cname
      importer.entries.each do |entry|
        next unless entry.is_a?
        service = klass.constantize.new(account, entry.becomes(Bulkrax::CsvEntry))
        service.validate
      end
    end
  end
end
