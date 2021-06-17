# frozen_string_literal: true

module HykuAddons
  class ValidateCsvImporterEntryJob < ApplicationJob
    # non_tenant_job
    def perform(account, entry)
      AccountElevator.switch! account.cname
      s = HykuAddons::Validations::CsvEntryValidationService.new(account, entry)
      s.validate
    end
  end
end
