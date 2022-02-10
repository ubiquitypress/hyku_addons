# frozen_string_literal: true
Hyrax::Autopopulation.configure do |config|
  config.is_hyrax_orcid_installed = true
  config.storage_type = "activerecord"
  config.app_name = "hyku_addons"
end
