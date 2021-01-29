# frozen_string_literal: true
module HykuAddons
  class InstitutionService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('institution', model: model)
    end
  end
end
