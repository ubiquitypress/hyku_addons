# frozen_string_literal: true


Hyrax::Orcid.configure do |config|
  config.work_reader = {
    meta_class_name: "::Bolognese::Metadata",
    from: "hyku_addons_work"
  }
end
