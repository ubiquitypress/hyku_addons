# frozen_string_literal: true

module HykuAddons
  class ValidateImporterEntryJob < ApplicationJob
    # non_tenant_job
    def perform(account, entry, source_service_options = {}, destination_service_options = {})
      AccountElevator.switch! account.cname
      s = HykuAddons::EntryValidationService.new(account, entry, source_service_options, destination_service_options)
      s.validate
    end
  end
end
