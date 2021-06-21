# frozen_string_literal: true

module HykuAddons
  class ValidateImporterEntryJob < ApplicationJob
    # non_tenant_job
    def perform(account, entry, source_service_options = {}, destination_service_options = {})
      AccountElevator.switch! account.cname
      service = HykuAddons::Validations::SolrEntryValidationService.new(account, entry, source_service_options, destination_service_options)
      service.validate
    end
  end
end
