# frozen_string_literal: true
module HykuAddons
  class InstitutionService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('institution', model: model, request: request)
    end
  end
end
