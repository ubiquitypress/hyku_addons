# frozen_string_literal: true
module HykuAddons
  class SubjectService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("subject", model: model, locale: locale)
    end
  end
end
