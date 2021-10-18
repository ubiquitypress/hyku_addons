# frozen_string_literal: true

module HykuAddons
  class ValidateCsvImporterEntryJob < ApplicationJob
    # non_tenant_job
    def perform(account, entry, klass = "HykuAddons::Validations::CsvEntryValidationService")
      AccountElevator.switch! account.cname
      service = klass.constantize.new(account, entry)
      service.validate
    end
  end
end
