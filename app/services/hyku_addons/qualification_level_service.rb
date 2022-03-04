# frozen_string_literal: true
module HykuAddons
  class QualificationLevelService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("qualification_level", model: model, locale: locale)
    end
  end
end
