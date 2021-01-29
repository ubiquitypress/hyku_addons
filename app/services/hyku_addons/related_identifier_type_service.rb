# frozen_string_literal: true
module HykuAddons
  class RelatedIdentifierTypeService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('related_identifier_type', model: model)
    end
  end
end
