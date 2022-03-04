# frozen_string_literal: true
module HykuAddons
  class VersionNumberService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("version_number", model: model, locale: locale)
    end
  end
end
