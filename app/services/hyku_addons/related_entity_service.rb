# frozen_string_literal: true
module HykuAddons
  class RelatedEntityService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("related_entity", model: model, locale: locale)
    end
  end
end
