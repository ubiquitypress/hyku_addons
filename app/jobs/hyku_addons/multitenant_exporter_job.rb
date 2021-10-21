# frozen_string_literal: true

# Elevates into the account passed as parameter before delegating the export to Bulkrax::ExporterJob
module HykuAddons
  class MultitenantExporterJob < ApplicationJob
    def perform(account_id, exporter_id)
      return if (account = Account.find(account_id)).blank?

      AccountElevator.switch!(account.cname)
      Bulkrax::ExporterJob.perform_now(exporter_id)
    end
  end
end
