# frozen_string_literal: true
module HykuAddons
  class QualificationLevelService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('qualification_level', model: model, request: request)
    end
  end
end
