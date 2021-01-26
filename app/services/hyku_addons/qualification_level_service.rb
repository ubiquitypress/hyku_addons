# frozen_string_literal: true
module HykuAddons
  class QualificationLevelService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('qualification_level', model: model)
    end
  end
end
