# frozen_string_literal: true
module HykuAddons
  class RelationTypeService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("relation_type", model: model, locale: locale)
    end
  end
end
