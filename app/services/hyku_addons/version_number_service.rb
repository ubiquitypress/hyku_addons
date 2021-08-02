# frozen_string_literal: true
module HykuAddons
  class VersionNumberService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('version_number', model: model)
    end
  end
end
