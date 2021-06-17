# frozen_string_literal: true

module HykuAddons
  class ValidateCsvImporterEntryJob < ApplicationJob
    # non_tenant_job
    def perform(account, entry)
      AccountElevator.switch! account.cname
      service = HykuAddons::Validations::CsvEntryValidationService.new(account, entry)
      service.validate
    end
  end
end
