# frozen_string_literal: true
module HykuAddons
  class QualificationNameService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("qualification_name", model: model, locale: locale)
    end
  end
end
