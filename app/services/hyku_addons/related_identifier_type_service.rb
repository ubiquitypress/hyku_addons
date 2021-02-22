# frozen_string_literal: true
module HykuAddons
  class RelatedIdentifierTypeService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('related_identifier_type', model: model, request: request)
    end
  end
end
