# frozen_string_literal: true

class ValidateImporterWorksJob < ApplicationJob
  # non_tenant_job

  def perform(account, importer)
    AccountElevator.switch! account.cname
    importer.entries.find_each do |entry|
      next if entry.is_a?(HykuAddons::CsvAdminSetEntry)
      s = EntryValidationService.new(account, entry)
      s.validate
    end
  end
end
