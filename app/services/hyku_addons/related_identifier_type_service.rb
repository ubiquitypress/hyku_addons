# frozen_string_literal: true
module HykuAddons
  class RelatedIdentifierTypeService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("related_identifier_type", model: model, locale: locale)
    end
  end
end
