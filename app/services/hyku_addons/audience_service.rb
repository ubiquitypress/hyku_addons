# frozen_string_literal: true
module HykuAddons
  class AudienceService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('audience', model: model)
    end
  end
end
