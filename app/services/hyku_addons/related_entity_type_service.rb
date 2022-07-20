# frozen_string_literal: true
module HykuAddons
  class RelatedEntityTypeService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("related_entity_type", model: model, locale: locale)
    end
  end
end
